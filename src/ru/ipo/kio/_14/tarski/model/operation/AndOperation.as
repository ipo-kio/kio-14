/**
 * @author: Vasily Akimushkin
 * @since: 21.01.14
 */
package ru.ipo.kio._14.tarski.model.operation {
import flash.utils.Dictionary;

import ru.ipo.kio._14.tarski.model.Figure;
import ru.ipo.kio._14.tarski.model.editor.LogicItem;

public class AndOperation extends TwoPositionOperation{
    private var and:String;


    public function AndOperation(and:String) {
        this.and = and;
        priority=4;
        super();
    }

    public override function resetPriority():void{
        priority=4;
    }

    override public function canBeEvaluated():Boolean {
        return operand1!=null && operand1.canBeEvaluated() && operand2!=null && operand2.canBeEvaluated();
    }

    override public function evaluate(data:Dictionary):Boolean{
        return operand1.evaluate(data) && operand2.evaluate(data);
    }

    override public function evaluateWithQuantsFinal(data:Dictionary, figures:Vector.<Figure>):Boolean{
        return operand1.evaluateWithQuants(data, figures) && operand2.evaluateWithQuants(data, figures);
    }

    public function toString():String {
        return quantsToSts()+"[" + operand1 + "&" +operand2+ "]";
    }



    public override function getToolboxText():String {
        return and;
    }

    public override function getCloned():LogicItem {
        return new AndOperation(and);
    }

}
}
