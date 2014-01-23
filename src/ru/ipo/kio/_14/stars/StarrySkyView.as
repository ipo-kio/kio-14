/**
 * Created by user on 06.01.14.
 */
package ru.ipo.kio._14.stars {
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

    public class StarrySkyView extends Sprite {

        private var starViews:Array;

        private var panel:InfoPanel;

        private var currentLine = -1;
        private var currentStar:int = -1;
        private var saveCurrentStar:int = -1;
        private var pressed:Boolean;

        private var lines:Array;
        private var sky:StarrySky;

        private var lineView:LineView;

        public function StarrySkyView(stars:Array) {

            panel = new InfoPanel(this);
            starViews = [];
            lines = [];

            for (var i:int = 0; i < stars.length; i++) {
                starViews[i] = new StarView(stars[i]);
                starViews[i].index = i;
            }

            sky = new StarrySky(starViews);

            drawSky();

            for (var k:int = 0; k < starViews.length; k++) {
                starViews[k].addEventListener(MouseEvent.ROLL_OVER, createRollOverListener(k));
            }

            for (var t:int = 0; t < starViews.length; t++) {
                starViews[t].addEventListener(MouseEvent.ROLL_OUT, function(e:MouseEvent):void {
                    currentStar = -1;
                });
            }

            //draw line
            addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
                if (currentStar != -1) {
                    saveCurrentStar = currentStar;
                    lineView = new LineView((getStarViewByIndex(currentStar)).x, (getStarViewByIndex(currentStar)).y, mouseX, mouseY);
                    pressed = true;
                }
            });

            addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void {
                if (pressed)
                    lineView = new LineView((getStarViewByIndex(currentStar)).x, (getStarViewByIndex(currentStar)).y, mouseX, mouseY);
//                lines.push([line, saveCurrentStar, currentStar]);
//                sky.addLine(saveCurrentStar, currentStar);
            });

            addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
                if (currentStar != -1 && currentStar != saveCurrentStar) {
                    lines.push([lineView, saveCurrentStar, currentStar]);
                    sky.addLine(saveCurrentStar, currentStar);
                    pressed = false;
                }
            });

            for (var s:int = 0; s < lines.length; s++) {
               lines[s][0].addEventListener(MouseEvent.ROLL_OVER, createRollOverListenerForLine(s));
            }

            for (var p:int = 0; p < lines.length; p++) {
                lines[p][0].addEventListener(MouseEvent.ROLL_OUT, function(e:MouseEvent):void {
                    currentLine = -1;
                });
            }

            addEventListener(MouseEvent.MOUSE_MOVE, function (e:Event):void {
                panel.text = "X coordinates: " + mouseX + ",\n" + "Y coordinates: " + mouseY + ",\n" + "current_Star: " + currentStar + ",\n" + "save_current_Star: " + saveCurrentStar;
            });

            addEventListener("add_new_line", function(e:Event):void {
                drawSky();
            });

            addEventListener("del_line", function(e:Event):void {
                drawSky();
            });


            panel.x = 0;
            panel.y = this.height;
            addChild(panel);
        }

        private function createRollOverListener(k:int):Function {
            return function(event:MouseEvent):void {
                currentStar = starViews[k].index;
            }
        }

        private function createRollOverListenerForLine(k:int):Function {
            return function(event:MouseEvent):void {
                currentLine = lines[k][0].lineIndex;
            }
        }

        private function getStarViewByIndex(ind:int):StarView {
            for (var i:int = 0; i < starViews.length; i++) {
                if (starViews[i].index == ind)
                    return starViews[i];
            }
            return null;
        }

//
//        private function createDeleteLineListener(k:int, line:LineView):Function {
//            return function(event:MouseEvent):void {
//                //по заданным индексам находим линию в массиве и уаляем её
//                for (var i:int; i < lines.length; i++) {
//
//                }
//                lines.push([line, saveCurrentStar, currentStar]);
//                sky.deleteLine(saveCurrentStar, currentStar);
//            }
//        }

        private function drawSky():void {

            graphics.clear();
            graphics.beginFill(0x0047ab);
            graphics.drawRect(0, 0, 500, 300);
            graphics.endFill();

            for (var i:int = 0; i < starViews.length; i++) {
                addChild(starViews[i]);
            }
        }
    }
}
