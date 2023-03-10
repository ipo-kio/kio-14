/**
 * Created by ilya on 11.01.14.
 */
package ru.ipo.kio._14.peterhof {

import flash.display.DisplayObject;

import ru.ipo.kio.api.KioApi;

import ru.ipo.kio.api.KioProblem;
import ru.ipo.kio.api.Settings;

public class PeterhofProblem implements KioProblem {

    public static const ID:String = 'peterhof';

    [Embed(source="loc/peterhof.ru.json-settings",mimeType="application/octet-stream")]
    public static var LOCALIZATION_RU:Class;
    [Embed(source="loc/peterhof.th.json-settings",mimeType="application/octet-stream")]
    public static var LOCALIZATION_TH:Class;


    [Embed(source="resources/icon.png")]
    public static var ICON:Class;

    [Embed(source="resources/about.png")]
    public static var ABOUT:Class;

    [Embed(source="resources/help.png")]
    public static var HELP:Class;

    private var _level:int;
    private var workspace:PeterhofWorkspace;

    public function PeterhofProblem(level:int) {
        _level = level;

        KioApi.initialize(this);

        KioApi.registerLocalization(ID, KioApi.L_RU, new Settings(LOCALIZATION_RU).data);
        KioApi.registerLocalization(ID, KioApi.L_TH, new Settings(LOCALIZATION_TH).data);

        workspace = new PeterhofWorkspace(this);
    }

    public function get id():String {
        return ID;
    }

    public function get year():int {
        return 2014;
    }

    public function get level():int {
        return _level;
    }

    public function get display():DisplayObject {
        return workspace;
    }

    public function get solution():Object {
        return workspace.currentSolution;
    }

    public function loadSolution(solution:Object):Boolean {
        return workspace.load(solution);
    }

    public function compare(solution1:Object, solution2:Object):int {
        if (solution1.total_length > solution2.total_length)
            return 1;
        else if (solution1.total_length < solution2.total_length)
            return -1;
        else
            return 0;
    }

    public function get icon():Class {
        return ICON;
    }

    public function get icon_help():Class {
        return HELP;
    }

    public function get icon_statement():Class {
        return ABOUT;
    }

    public function clear():void {
        workspace.clear();
    }
}
}
