/**
 * Created by IntelliJ IDEA.
 * User: ilya
 * Date: 13.02.12
 * Time: 23:41
 */
package ru.ipo.kio._12.diamond.model {
import flash.events.Event;
import flash.events.EventDispatcher;

import ru.ipo.kio._12.diamond.GeometryUtils;

import ru.ipo.kio._12.diamond.Vertex2D;

public class Diamond extends EventDispatcher {

    private var _vertices:Array/*Vertex2D*/ = [];
    private var _hull:Array/*Vertex2D*/ = [];

    public static const UPDATE:String = 'vertices update';
    private static const UPDATE_EVENT:Event = new Event(UPDATE);

    public function Diamond() {
    }

    private function update_convex_hull():void {
        trace(_vertices);
        _hull = GeometryUtils.convex_hull(_vertices);
    }

    public function addVertex(v:Vertex2D):void {
        v.addEventListener(Vertex2D.MOVE, vertex_moved);
        _vertices.push(v);
        update_convex_hull();
        dispatchEvent(UPDATE_EVENT);
    }

    public function removeVertex(v:Vertex2D):void {
        removeVertexByIndex(_vertices.indexOf(v));
        update_convex_hull();
        dispatchEvent(UPDATE_EVENT);
    }

    private function removeVertexByIndex(ind:int):void {
        if (ind < 0 || ind >= _vertices.length)
            return;
        
        _vertices[ind].removeEventListener(Vertex2D.MOVE, vertex_moved);
        
        _vertices.splice(ind, 1);

        update_convex_hull();
        dispatchEvent(UPDATE_EVENT);
    }
    
    public function getVertex(ind:int):Vertex2D {
        return _vertices[ind];
    }
    
    public function getHullVertex(ind:int):Vertex2D {
        return _hull[ind];
    }
    
    public function get vertexCount():int {
        return _vertices.length;
    }

    public function get hullVertexCount():int {
        return _hull.length;
    }
    
    public function setVertex(ind:int, v:Vertex2D):void {
        _vertices[ind].removeEventListener(Vertex2D.MOVE, vertex_moved);
        _vertices[ind] = v;
        v.addEventListener(Vertex2D.MOVE, vertex_moved);

        update_convex_hull();
        dispatchEvent(UPDATE_EVENT);
    }

    private function vertex_moved(event:Event):void {
        update_convex_hull();
        dispatchEvent(UPDATE_EVENT);
    }
}
}