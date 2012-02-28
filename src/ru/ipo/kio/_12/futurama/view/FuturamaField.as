/**
 * Created by IntelliJ IDEA.
 * User: ilya
 * Date: 26.02.12
 * Time: 14:00
 * To change this template use File | Settings | File Templates.
 */
package ru.ipo.kio._12.futurama.view {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

import ru.ipo.kio._12.futurama.FuturamaProblem;

import ru.ipo.kio._12.futurama.model.Permutation;
import ru.ipo.kio.api.KioApi;
import ru.ipo.kio.api.TextUtils;
import ru.ipo.kio.api.controls.RecordBlinkEffect;
import ru.ipo.kio.base.displays.ShellButton;

public class FuturamaField extends Sprite {

    [Embed(source='../resources/Exchange_Field.png')]
    private static const BG:Class;

    private var _forbiddenBases:ForbiddenMovesView;
    private var _forbiddenValues:ForbiddenMovesView;
    
    private var steps_value:TextField;
    private var steps_record_value:TextField;
    
    private var record_steps:int = 0;
    
    private var _perm:Permutation;
    
    public function FuturamaField(n:int, level:int) {

        addChild(new BG);
        
        _perm = new Permutation(n);

        var moves:PermutationPanel = new PermutationPanel(this, _perm, level);
        moves.x = FuturamaGlobalMetrics.LEFT_PANEL_WIDTH + 13;
        moves.y = 7;
        addChild(moves);
        
        _forbiddenBases = new ForbiddenMovesView(_perm, true, level);
        _forbiddenValues = new ForbiddenMovesView(_perm, false, level);
        
        _forbiddenBases.x = 7;
        _forbiddenBases.y = 7;
        _forbiddenValues.x = 7;
        _forbiddenValues.y = FuturamaGlobalMetrics.LEFT_PANEL_HEIGHT + 13;

        addChild(_forbiddenBases);
        addChild(_forbiddenValues);
        
        //permutations list view
        var list_view_base:PermutationListView = new PermutationListView(_perm, true);
        var list_view_values:PermutationListView = new PermutationListView(_perm, false);
        
        list_view_base.x = _forbiddenValues.x + _forbiddenValues.width + 6;
        list_view_base.y = moves.y + moves.height + 2;
        list_view_values.x = list_view_base.x + list_view_base.width + 1;
        list_view_values.y = list_view_base.y;
        
        addChild(list_view_base);
        addChild(list_view_values);

        var backButton:ShellButton = new ShellButton('Назад');
        var forwardButton:ShellButton = new ShellButton('Вперед');
        
        backButton.x = list_view_values.x + list_view_base.width + 1;
        backButton.y = list_view_values.y;
        addChild(backButton);

        forwardButton.x = backButton.x;
        forwardButton.y = backButton.y + backButton.height + 3;
        addChild(forwardButton);
        
        backButton.addEventListener(MouseEvent.CLICK, function(event:Event):void {
            _perm.undo();
        });
        forwardButton.addEventListener(MouseEvent.CLICK, function(event:Event):void {
            _perm.redo();
        });

        //values
        var steps_text:TextField = TextUtils.createTextFieldWithFont('KioTahoma', 16, false);
        var steps_record_text:TextField = TextUtils.createTextFieldWithFont('KioTahoma', 16, false);

        steps_value = TextUtils.createTextFieldWithFont('KioTahoma', 16, false);
        steps_record_value = TextUtils.createTextFieldWithFont('KioTahoma', 16, false);

        steps_text.textColor = 0x444400;
        steps_record_text.textColor = 0x444400;
        steps_value.textColor = 0x000000;
        steps_record_value.textColor = 0x000000;

        steps_text.text = 'Обменов:';
        steps_record_text.text = 'Рекорд:';

        steps_value.text = '0';
        steps_record_value.text = '0';
        
        steps_text.x = forwardButton.x;
        steps_text.y = forwardButton.y + forwardButton.height + 4;
        addChild(steps_text);

        steps_record_text.x = steps_text.x;
        steps_record_text.y = steps_text.y + steps_text.textHeight + 2;
        addChild(steps_record_text);
        
        steps_value.x = steps_text.x + Math.max(steps_text.textWidth, steps_text.textWidth) + 6;
        steps_value.y = steps_text.y;
        addChild(steps_value);

        steps_record_value.x = steps_value.x;
        steps_record_value.y = steps_record_text.y;
        addChild(steps_record_value);
        
        _perm.addEventListener(Permutation.PERMUTATION_CHANGED, update_everything);
    }

    private function update_everything(event:Event = null):void {
        var api:KioApi = KioApi.instance(FuturamaProblem.ID);
        
        api.autoSaveSolution();
        
        var new_steps:int = _perm.base_transpositions.length;
        
        steps_value.text = '' + new_steps;
        
        if (new_steps > record_steps) {
            api.saveBestSolution();
            record_steps = new_steps;
            RecordBlinkEffect.blink(
                    this,
                    steps_record_value.x - 2,
                    steps_record_value.y,
                    steps_record_value.textWidth + 10,
                    steps_record_value.textHeight + 2
            );
            
            steps_record_value.text = '' + new_steps;
        }
    }

    public function get forbiddenBases():ForbiddenMovesView {
        return _forbiddenBases;
    }

    public function get forbiddenValues():ForbiddenMovesView {
        return _forbiddenValues;
    }

    public function get perm():Permutation {
        return _perm;
    }
}
}
