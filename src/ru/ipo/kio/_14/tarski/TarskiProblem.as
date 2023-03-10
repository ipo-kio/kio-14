/**
 * @author: Vasily Akimushkin
 * @since: 31.01.14
 */
package ru.ipo.kio._14.tarski {
import com.nerdbucket.ToolTip;

import flash.display.Sprite;
import flash.display.Stage;



import flash.display.DisplayObject;
import flash.events.Event;

import ru.ipo.kio._14.tarski.model.ConfigurationHolder;

import ru.ipo.kio.api.KioApi;
import ru.ipo.kio.api.KioProblem;
import ru.ipo.kio.api.Settings;
import ru.ipo.kio.base.KioBase;

public class TarskiProblem implements KioProblem{

    public static const ID:String = "Tarski";

    public static const YEAR:int = 2014;

    [Embed(source='_resources/icon.png')]
    public static var INTRO:Class;

    [Embed(source='_resources/about.jpg')]
    private static var ABOUT:Class;

    [Embed(source='_resources/help.png')]
    private static var HELP:Class;

    [Embed(source='_resources/about0.jpg')]
    private static var ABOUT0:Class;

    [Embed(source='_resources/help0.png')]
    private static var HELP0:Class;

    [Embed(source="loc/Tarski.ru.json-settings",mimeType="application/octet-stream")]
    public static var TARSKI_RU:Class;
//    [Embed(source="loc/Tarski.es.json-settings",mimeType="application/octet-stream")]
//    public static var TARSKI_ES:Class;
//    [Embed(source="loc/Tarski.en.json-settings",mimeType="application/octet-stream")]
//    public static var TARSKI_EN:Class;
//    [Embed(source="loc/Tarski.bg.json-settings",mimeType="application/octet-stream")]
//    public static var TARSKI_BG:Class;
    [Embed(source="loc/Tarski.th.json-settings",mimeType="application/octet-stream")]
    public static var TARSKI_TH:Class;

    private var _level:int;

    private var _sprite:Sprite;


    public function TarskiProblem(level:int, stage:Stage) {
        _level=level;
        KioApi.initialize(this);
        if(level ==0){
            _sprite = new TarskiProblemZero(this);
        }else{
            _sprite=new TarskiProblemFirst(level, stage, this);
        }
        KioApi.registerLocalization(ID, KioApi.L_RU, new Settings(TARSKI_RU).data);
//        KioApi.registerLocalization(ID, KioApi.L_ES, new Settings(TARSKI_ES).data);
//        KioApi.registerLocalization(ID, KioApi.L_EN, new Settings(TARSKI_EN).data);
//        KioApi.registerLocalization(ID, KioApi.L_BG, new Settings(TARSKI_BG).data);
        KioApi.registerLocalization(ID, KioApi.L_TH, new Settings(TARSKI_TH).data);
    }

    public function get id():String {
        return ID;
    }

    public function get year():int {
        return YEAR;
    }

    public function get level():int {
        return _level;
    }

    public function get display():DisplayObject {
        return _sprite;
    }

    public function get solution():Object {
        if(level==0){
            return {config:TarskiProblemZero.instance.configuration.toString()};
        }else{
            return {statement:TarskiProblemFirst.instance.statementManager.getStatementAsJson()};
        }
    }

    public function loadSolution(solution:Object):Boolean {
        if(level==0){
            var config:String = solution.config;
            TarskiProblemZero.instance.configuration.loadFigures(config);
            TarskiProblemZero.instance.update();
        }else{
            var statements:Array = solution.statement;
            TarskiProblemFirst.instance.statementManager.load(statements);
            TarskiProblemFirst.instance.update();
        }
        return true;
    }

    public function check(solution:Object):Object {
        return null;
    }

    public function get best():Object {
        if(level==0){
        return {
            statements: TarskiProblemZero.instance.getAmountOfCorrectStatements(),
            figures: TarskiProblemZero.instance.configuration.figures.length
        };
        }else{ return {
            statements: ConfigurationHolder.instance.getRightSelectionAmount(),
            length: TarskiProblemFirst.instance.statementManager.getLength()
        };
        }
    }

    public function compare(solution1:Object, solution2:Object):int {
        if (!solution1){
            return solution2 ? -1 : 0;
        } else if (!solution2){
            return 1;
        }
         if(level==0){
            if(solution1.statements!=solution2.statements){
                return getSign(solution1.statements-solution2.statements);
            }else{
                return getSign(solution1.figures-solution2.figures);
            }
         }else{
             if(solution1.length==0){
                 return solution2.length==0?0:-1;
             }else if (solution2.length==0){
                 return 1;
             }
             if(solution1.statements!=solution2.statements){
                 return getSign(solution1.statements-solution2.statements);
             }else{
                 return getSign(solution2.length-solution1.length);
             }
         }

    }

    private function getSign(i:Number):int {
        return i>0?1:i<0?-1:0;
    }


    public function get icon():Class {
        return INTRO;
    }

    public function get icon_help():Class {
       return level == 0 ? HELP0 : HELP;
    }

    public function get icon_statement():Class {
        return level == 0 ? ABOUT0 : ABOUT;
    }

    public function clear():void{
      if(level==0){
          TarskiProblemZero.instance.clearFigures();
      } else{
          TarskiProblemFirst.instance.statementManager.clearAll();
      }
    }

}
}
