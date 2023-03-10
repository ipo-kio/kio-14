/**
 * Предикат, проверяющий цвет объекта
 *
 * @author: Vasily Akimushkin
 * @since: 21.01.14
 */
package ru.ipo.kio._14.tarski.model.predicates {
import flash.errors.IllegalOperationError;
import flash.utils.Dictionary;

import ru.ipo.kio._14.tarski.model.editor.LogicItem;
import ru.ipo.kio._14.tarski.model.properties.ColorValue;
import ru.ipo.kio._14.tarski.model.properties.Colorable;
import ru.ipo.kio._14.tarski.model.properties.ValueHolder;

public class ColorPredicate extends OnePlacePredicate{

    /**
     * Проверяемый цвет
     */
    private var color:ColorValue;
    private var red:String;
    private var blue:String;


     public function ColorPredicate(color:ColorValue, red:String, blue:String) {
        this.color = color;
         this.red =red;
         this.blue =blue;

         super();
    }



    override public function canBeEvaluated():Boolean {
        return formalOperand!=null;
    }

    override public function evaluate(data:Dictionary):Boolean {
        var operand:Colorable=data[formalOperand];
        if(operand==null){
            throw new IllegalOperationError("operand must be not null");
        }
        return color.code==operand.color.code;
    }


    public override function toString():String {
        return quantsToSts()+"color-"+color.code+"-"+formalOperand+"";
    }

    public function parseString(str:String):ColorPredicate {
        var items:Array = str.split("-");
        color = ValueHolder.getColor(items[1]);
        if(items[2]!="null"){
            operand = items[2];
            placeHolder.variable = new Variable(formalOperand);
        }
        return this;
    }

    public override function getToolboxText():String {
        return color.code==ColorValue.RED?red:blue;
    }

    public override function getCloned():LogicItem {
        return new ColorPredicate(color, red, blue);
    }
}
}
