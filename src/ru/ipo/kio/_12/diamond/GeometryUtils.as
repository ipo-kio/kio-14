/**
 * Created by IntelliJ IDEA.
 * User: ilya
 * Date: 12.02.12
 * Time: 11:16
 * To change this template use File | Settings | File Templates.
 */
package ru.ipo.kio._12.diamond {

public class GeometryUtils {

    //positive for CCV
    public static function vect_prod(v10:Vertex2D, v11:Vertex2D, v20:Vertex2D, v21:Vertex2D):Number {
        var x1:Number = v11.x - v10.x;
        var y1:Number = v11.y - v10.y;
        var x2:Number = v21.x - v20.x;
        var y2:Number = v21.y - v20.y;

        return x1 * y2 - x2 * y1;
    }

    public static function scal_prod(v10:Vertex2D, v11:Vertex2D, v20:Vertex2D, v21:Vertex2D):Number {
        var x1:Number = v11.x - v10.x;
        var y1:Number = v11.y - v10.y;
        var x2:Number = v21.x - v20.x;
        var y2:Number = v21.y - v20.y;

        return x1 * x2 + y1 * y2;
    }
    
    public static function convex_hull(poly:Array/*Vertex2D*/):Array/*Vertex2D*/ {
        poly = poly.slice();
        
        if (poly.length < 3)
            return poly;

        //find the leftmost point of the lowest points
        var p0:Vertex2D = poly[0];
        var p0_ind:int = 0;
        
        for (var i:int = 1; i < poly.length; i++) {
            var p:Vertex2D = poly[i];
            if (p.y < p0.y || p.y == p0.y && p.x < p0.x) {
                p0 = p;
                p0_ind = i;
            }
        }

        //exchange points
        poly[p0_ind] = poly[0];
        poly[0] = p0;

        //sort by angle, bubble sort.
        for (i = 1; i < poly.length; i++)
            for (var j:int = i + 1; j < poly.length; j++) {
                //compare poly[i] and poly[j]
                var mul:Number = vect_prod(p0, poly[i], p0, poly[j]);

                var exchange:Boolean = false;
                if (mul < 0)
                    exchange = true;
                else if (mul === 0) {
                    var dxi:Number = poly[i].x - p0.x;
                    var dxj:Number = poly[j].x - p0.x;
                    var dyi:Number = poly[i].y - p0.y;
                    var dyj:Number = poly[j].y - p0.y;
                    exchange = dxi*dxi + dyi*dyi > dxj*dxj + dyj*dyj;
                }
                
                if (exchange) {
                    var tmp:Vertex2D = poly[i];
                    poly[i] = poly[j];
                    poly[j] = tmp;
                }
            }
        
        trace('after angles sort:');
        trace(poly);

        var stack:Array = new Array(p0, poly[1]);
        for (i = 2; i < poly.length; i++)
            while (true) {
                var len:int = stack.length;
                
                if (len < 2) {
                    stack.push(poly[i]);
                    break;
                }
                
                var next_to_top:Vertex2D = stack[len - 2];
                var top:Vertex2D = stack[len - 1];

                mul = vect_prod(next_to_top, top, top, poly[i]);
                
                var stop_popping:Boolean = false;
                if (mul > 0)
                    stop_popping = true;
                if (mul == 0)
                    stop_popping = scal_prod(next_to_top, top, top, poly[i]) < 0;
                
                if (stop_popping) {
                    stack.push(poly[i]);
                    break;
                }

                stack.pop();
            }
        
        return stack;
    }

    //returns a, b, c
    public static function points2line(v1:Vertex2D, v2:Vertex2D):Array {
        //x - x1 / x2 - x1 = y - y1 / y2 - y1
        //c = y1*(x2-x1) - x1*(y2 - y1) = y1 * x2 - x1 * y2;
        return [
                v2.y - v1.y,
                v1.x - v2.x,
                v1.y * v2.x - v1.x * v2.y
        ];
    }
    
    public static function intersect_lines(l1:Array, l2:Array):Vertex2D {
        //a1 b1 = -c1
        //a2 b2 = -c2
        var d:Number = l1[0]*l2[1] - l1[1]*l2[0];
        var d1:Number = - l1[2]*l2[1] + l2[2]*l1[1];
        var d2:Number = - l1[0]*l2[2] + l2[0]*l1[2];
        
        if (d == 0)
            return null;
        
        return new Vertex2D(d1 / d, d2 / d);
    }
    
    public static function line_value(line:Array, p:Vertex2D):Number {
        return line[0] * p.x + line[1] * p.y + line[2];
    }

    //null means no intersection
    public static function intersect_ray_and_segment(r0:Vertex2D, r1:Vertex2D, s1:Vertex2D, s2:Vertex2D):Vertex2D {
        var ray_line:Array = points2line(r0, r1);
        var d1:Number = line_value(ray_line, s1);
        var d2:Number = line_value(ray_line, s2);

        if (d1 * d2 > 0)
            return null;
        
        var seg_line:Array = points2line(s1, s2);
        var intersection:Vertex2D = intersect_lines(ray_line, seg_line);

        if (intersection == null)
            return null;

        if (scal_prod(r0, r1, r0, intersection) < 0)
            return null;
        
        return intersection;
    }

    public static function normal_for_segment(s1:Vertex2D, s2:Vertex2D):Vertex2D {
        var x:Number = s1.y - s2.y;
        var y:Number = s2.x - s1.x;

        var l:Number = Math.sqrt(x * x + y * y);
        
        return new Vertex2D(x / l,  y / l);
    }

    //r1 lays on segment, returns a point such that r1-p is the reflected ray
    public static function reflect_ray(r0:Vertex2D, r1:Vertex2D, s1:Vertex2D, s2:Vertex2D, eta:Number) {
        //reflected vector = r
        //initial vector = i
        //normal vector = n
        //i - 2 * (i*n) * n

        var n:Vertex2D = normal_for_segment(s1, s2);
        //test n goes to the incoming half-plane


    }

}
}