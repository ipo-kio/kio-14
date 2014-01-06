/**
 * Created by user on 06.01.14.
 */
package ru.ipo.kio._14.stars {
import flash.display.Sprite;

    public class StarView extends Sprite {

        private var star:Star;
        private var isSelected:Boolean;

        public function StarView(star:Star) {
            this.star = star;
            isSelected = (mouseX >= (star.x - star.radius) && mouseX <= (star.x + star.radius)) && (mouseY >= (star.y - star.radius) && mouseY <= (star.y + star.radius));

            draw();
        }

        private function draw():void {
            if (isSelected) {
                graphics.clear();
                graphics.beginFill(0xffcc00);
                graphics.drawCircle(star.x, star.y, star.radius + 3);
                graphics.endFill();
            } else {
                graphics.clear();
                graphics.beginFill(0xfcdd76);
                graphics.drawCircle(star.x, star.y, star.radius);
                graphics.endFill();
            }
        }
    }
}
