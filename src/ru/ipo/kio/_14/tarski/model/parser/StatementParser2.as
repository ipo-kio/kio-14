/**
 * @author: Vasily Akimushkin
 * @since: 11.02.14
 */
package ru.ipo.kio._14.tarski.model.parser {
import flash.sampler.isGetterSetter;
import flash.utils.Dictionary;

import mx.controls.ProgressBarLabelPlacement;

import mx.logging.LogLogger;

import ru.ipo.kio._14.tarski.TarskiRunner;
import ru.ipo.kio._14.tarski.TarskiProblemFirst;

import ru.ipo.kio._14.tarski.model.editor.LogicItem;
import ru.ipo.kio._14.tarski.model.operation.AndOperation;
import ru.ipo.kio._14.tarski.model.operation.BaseOperation;
import ru.ipo.kio._14.tarski.model.operation.Brace;
import ru.ipo.kio._14.tarski.model.operation.EquivalenceOperation;
import ru.ipo.kio._14.tarski.model.operation.ImplicationOperation;
import ru.ipo.kio._14.tarski.model.operation.LogicEvaluatedItem;
import ru.ipo.kio._14.tarski.model.operation.NotOperation;
import ru.ipo.kio._14.tarski.model.operation.OrOperation;
import ru.ipo.kio._14.tarski.model.operation.TwoPositionOperation;
import ru.ipo.kio._14.tarski.model.predicates.BasePredicate;
import ru.ipo.kio._14.tarski.model.predicates.OnePlacePredicate;
import ru.ipo.kio._14.tarski.model.predicates.TwoPlacePredicate;
import ru.ipo.kio._14.tarski.model.predicates.Variable;

import ru.ipo.kio._14.tarski.model.quantifiers.Quantifier;
import ru.ipo.kio._14.tarski.view.statement.FictiveLogicItem;
import ru.ipo.kio.api.KioApi;

public class StatementParser2 extends StatementParser1{
    private var autoQuantors:Boolean = false;
    private var api:KioApi;

    public function StatementParser2(api:KioApi, autoQuantors:Boolean=false) {
       this.api=api;
       this.autoQuantors=autoQuantors;
    }

    public override function parse(logicItemsInit:Vector.<LogicItem>):LogicEvaluatedItem {
        var logicItems:Vector.<LogicItem> = new Vector.<LogicItem>();
        for(var i:int=0; i<logicItemsInit.length; i++){
            logicItems.push(logicItemsInit[i]);
        }

//        processIfThen(logicItems);

        var correctBraces:Boolean = setPrioirtiesAndCheckBraces(logicItems);
        if(!correctBraces){
            return null;
        }

        if(!autoQuantors){
        var quantOperand:Vector.<String> = new Vector.<String>();
        for(var i:int=0; i<logicItems.length; i++){
            if(logicItems[i] is Quantifier) {
                if (Quantifier(logicItems[i]).placeHolder.variable == null) {
                    return null;
                }
                if (quantOperand.indexOf(Quantifier(logicItems[i]).placeHolder.variable.code) >= 0) {
                    //???????????????????? ?? ?????????????????? ???????????? ???????? ????????????
                    return null;
                }
                if (i == logicItems.length - 1) {
                    //?????????????? ???? ?????????? ???????????? ?? ??????????
                    return null;
                } else if (logicItems[i + 1] is TwoPositionOperation) {
                    //?????????????? ???? ?????????? ???????????? ?????????? ?????????????? two position operation
                    return null;
                }
                if (!variableExistsRight(i, logicItems) || variableExistsLeft(i, logicItems)) {
                    return null;
                }
                quantOperand.push(Quantifier(logicItems[i]).placeHolder.variable.code);
            }
        }
        }

        logicItems = removeBracesAndClearQuantifiers(logicItems);
        var result:LogicEvaluatedItem = parseByPriority(logicItems);
        if(autoQuantors && result!=null){
            result.commit();
            var dict:Dictionary = result.collectFormalOperand();
            for (var k:Object in dict) {
                var quant:Quantifier = new Quantifier(Quantifier.ALL);
                quant.operand=dict[k];
                quant.placeHolder.variable=new Variable(dict[k]);
                result.quants.push(quant);

            }
        }
        trace(result);
        if(result!=null){
            result.commit();

            if(!autoQuantors){

            if(countKeys(result.collectFormalOperand())!=quantOperand.length){
                return null;
            }

            if(!result.checkQuantors(new Vector.<Quantifier>())){
                return null;
            }
            }

//            for(var i:int=0; i<quantOperand.length; i++){
//                var quant:Quantifier = new Quantifier(Quantifier.EXIST);
//                quant.placeHolder.variable=new Variable(quantOperand[i]);
//                //???????? ?????????????????????? ????????????????????, ???????????????????? ?????????????????? ???????????????????? ?? ?????????????????????? ?????? ??????????????
//                pushQuantor(result, quant);
//            }
        }
        return result;
    }

    /**
     * ???????????????? ???????? ... ???? ...
     * ???? ((...)<=> ...)#, ?????? # - ???????????? ???????????????? => ?????? <=> ?????? ????????????
     * @param logicItems
     */
    public function  processIfThen(logicItems:Vector.<LogicItem>){
        for(var i:int=0; i<logicItems.length; i++){
            if(logicItems[i] is FictiveLogicItem && FictiveLogicItem(logicItems[i]).getFormulaText()==FictiveLogicItem.IF){
                logicItems.splice(i, 1, new Brace(true), new Brace(true));
            }else if(logicItems[i] is FictiveLogicItem && FictiveLogicItem(logicItems[i]).getFormulaText()==FictiveLogicItem.THEN){
                logicItems.splice(i, 1, new Brace(false), new ImplicationOperation(api.localization.buttons.impl, api.localization.hints.impl));
                i++;
                var braceCount:int = 0 ;
                for(var j:int = i+1; j<logicItems.length; j++){
                    if(logicItems[j] is Brace){
                        braceCount=Brace(logicItems[j]).open?(braceCount+1):(braceCount-1);
                    }else if(braceCount==0 && (logicItems[j] is ImplicationOperation || logicItems[j] is EquivalenceOperation)){
                        logicItems.splice(j, 0, new Brace(false));
                        break;
                    }

                    if(j==logicItems.length-1){
                        logicItems.splice(j+1, 0, new Brace(false));
                        break;
                    }
                }
            }
        }

    }

    public static function countKeys(myDictionary:flash.utils.Dictionary):int
    {
        var n:int = 0;
        for (var key:* in myDictionary) {
            n++;
        }
        return n;
    }

    private function pushQuantor(result:LogicEvaluatedItem, quant:Quantifier):void {
        if(result is BasePredicate){//???????????? ???????????? ????????????
            result.quants.push(quant);
        }else if(result is NotOperation){//???????????? ?????????????? ?? ????????????????????
            pushQuantor(NotOperation(result).operand, quant);
        }else if(result is TwoPositionOperation){
            var inFirst:Boolean = TwoPositionOperation(result).operand1.collectFormalOperand()[quant.placeHolder.variable.code];
            var inSecond:Boolean = TwoPositionOperation(result).operand2.collectFormalOperand()[quant.placeHolder.variable.code];
            if(inFirst && inSecond){
                result.quants.push(quant);
            }else if (inFirst){
                pushQuantor(TwoPositionOperation(result).operand1, quant);
            }else{
                pushQuantor(TwoPositionOperation(result).operand2, quant);
            }
        }
    }



    private function variableExistsRight(i:int, logicItems:Vector.<LogicItem>):Boolean {
        var exist:Boolean = false;
        for (var j:int = i + 1; j < logicItems.length; j++) {
            if (logicItems[j] is OnePlacePredicate) {
                if (OnePlacePredicate(logicItems[j]).placeHolder.variable != null &&
                        OnePlacePredicate(logicItems[j]).placeHolder.variable.code ==
                                Quantifier(logicItems[i]).placeHolder.variable.code) {
                    exist = true;
                }
            } else if (logicItems[j] is TwoPlacePredicate) {
                if (TwoPlacePredicate(logicItems[j]).placeHolder1.variable != null &&
                        TwoPlacePredicate(logicItems[j]).placeHolder1.variable.code ==
                                Quantifier(logicItems[i]).placeHolder.variable.code) {
                    exist = true;
                }
                if (TwoPlacePredicate(logicItems[j]).placeHolder2.variable != null &&
                        TwoPlacePredicate(logicItems[j]).placeHolder2.variable.code ==
                                Quantifier(logicItems[i]).placeHolder.variable.code) {
                    exist = true;
                }
            }
        }
        return exist;
    }

    private function variableExistsLeft(i:int, logicItems:Vector.<LogicItem>):Boolean {
        var exist:Boolean = false;
        for (var j:int = 0; j < i; j++) {
            if (logicItems[j] is OnePlacePredicate) {
                if (OnePlacePredicate(logicItems[j]).placeHolder.variable != null &&
                        OnePlacePredicate(logicItems[j]).placeHolder.variable.code ==
                                Quantifier(logicItems[i]).placeHolder.variable.code) {
                    exist = true;
                }
            } else if (logicItems[j] is TwoPlacePredicate) {
                if (TwoPlacePredicate(logicItems[j]).placeHolder1.variable != null &&
                        TwoPlacePredicate(logicItems[j]).placeHolder1.variable.code ==
                                Quantifier(logicItems[i]).placeHolder.variable.code) {
                    exist = true;
                }
                if (TwoPlacePredicate(logicItems[j]).placeHolder2.variable != null &&
                        TwoPlacePredicate(logicItems[j]).placeHolder2.variable.code ==
                                Quantifier(logicItems[i]).placeHolder.variable.code) {
                    exist = true;
                }
            }
        }
        return exist;
    }


    public function parseByPriority(logicItems:Vector.<LogicItem>):LogicEvaluatedItem {

        var index:int = getIndexOfLowest(logicItems);
        if(index>=0){
            var logicItem:LogicItem = logicItems[index];
            if(logicItem is EquivalenceOperation){
                var equivalence:EquivalenceOperation = new EquivalenceOperation(api.localization.buttons.eqv, api.localization.hints.eqv);
                equivalence.operand1=parseByPriority(logicItems.slice(0,index));
                equivalence.operand2=parseByPriority(logicItems.slice(index+1));
                return equivalence;
            }else if(logicItem is ImplicationOperation){
                var implication:ImplicationOperation = new ImplicationOperation(api.localization.buttons.impl, api.localization.hints.impl);
                implication.operand1=parseByPriority(logicItems.slice(0,index));
                implication.operand2=parseByPriority(logicItems.slice(index+1));
                return implication;
            }else if(logicItem is AndOperation){
                var andOperation:AndOperation = new AndOperation(api.localization.buttons.and);
                andOperation.operand1=parseByPriority(logicItems.slice(0,index));
                andOperation.operand2=parseByPriority(logicItems.slice(index+1));
                return andOperation;
            }else if(logicItem is OrOperation){
                var orOperation:OrOperation = new OrOperation(api.localization.buttons.or);
                orOperation.operand1=parseByPriority(logicItems.slice(0,index));
                orOperation.operand2=parseByPriority(logicItems.slice(index+1));
                return orOperation;
            }else if(logicItem is NotOperation && index==0){
                var notOperation = new NotOperation();
                notOperation.operand=parseByPriority(logicItems.slice(index+1));
                return notOperation;
            }else if(logicItem is Quantifier && index==0){
                var quants:Vector.<Quantifier>  = new Vector.<Quantifier>();
                var quantIndex:int=index;
                for(quantIndex;quantIndex<logicItems.length ; quantIndex++){
                    if(logicItems[quantIndex] is Quantifier){
                        quants.push(logicItems[quantIndex]);
                    }else{
                        quantIndex--;
                        break;
                    }
                }
                var operation:LogicEvaluatedItem = parseByPriority(logicItems.slice(quantIndex+1));
                if(quants.length>3){
                    return null;
                }
                for(var i:int=0; i<quants.length; i++){
                    operation.quants.push(quants[i]);
                }
                return operation;
            }
        }else{
            if(logicItems.length==1 && logicItems[0] instanceof BasePredicate){
                return BasePredicate(logicItems[0]);
            }
        }
        return null;
    }

    protected function getIndexOfLowest(logicItems:Vector.<LogicItem>):int {
        var priority:int=1000;
        var index:int=-1;
        for (var i:int = 0; i < logicItems.length; i++) {
            if (logicItems[i] is BaseOperation) {
                if(priority>(BaseOperation(logicItems[i])).priority){
                    index=i;
                    priority=(BaseOperation(logicItems[i])).priority;
                }
            }else if (logicItems[i] is Quantifier) {
                if(priority>(Quantifier(logicItems[i])).priority){
                    index=i;
                    priority=(Quantifier(logicItems[i])).priority;
                }
            }
        }
        return index;
    }

    private function removeBracesAndClearQuantifiers(logicItems:Vector.<LogicItem>):Vector.<LogicItem> {
        for (var i:int = logicItems.length - 1; i >= 0; i--) {
            if (logicItems[i] instanceof Brace) {
                logicItems.splice(i, 1);
            }else if(logicItems[i] is LogicEvaluatedItem){
              LogicEvaluatedItem(logicItems[i]).quants=new Vector.<Quantifier>();
            }
        }
        return logicItems;
    }


    private function setPrioirtiesAndCheckBraces(logicItems:Vector.<LogicItem>):Boolean {
        var braceCount:int = 0;
        for (var i:int = 0; i < logicItems.length; i++) {
            if (logicItems[i] instanceof Brace) {
                var brace:Brace = Brace(logicItems[i]);
                if (brace.open) {
                    braceCount++;
                } else {
                    braceCount--;
                    if (braceCount < 0) {
                        return false;
                    }
                }
            } else {
                if (logicItems[i] is BaseOperation) {
                    ((BaseOperation)(logicItems[i])).resetPriority();
                    ((BaseOperation)(logicItems[i])).priority += braceCount * 10;
                }else if(logicItems[i] is Quantifier){
                    ((Quantifier)(logicItems[i])).resetPriority();
                    ((Quantifier)(logicItems[i])).priority += braceCount * 10;
                }

            }
        }

        if (braceCount != 0) {
            return false;
        }
        return true;
    }


}
}
