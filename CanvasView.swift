//
//  CanvasView.swift
//  UserInteractionWithLayers
//
//  Created by Daniel Farrell on 06/04/2015.
//  Copyright (c) 2015 Daniel Farrell. All rights reserved.
//

import Cocoa

func highlightShapeLayer(shape : CAShapeLayer) {
    shape.lineWidth = 4.0
}

func removeHighlightOnShapeLater(shape : CAShapeLayer) {
    shape.lineWidth = 0.0
}

func updateLayerPropertyWithoutAnimations( layer: CALayer, process : (layer : CALayer) -> () ) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    process(layer: layer)
    CATransaction.commit()
}

class CanvasView: NSView {

    var layersSelectedByDrag : Set<CALayer> = Set()
    var layerSelectedByClick : CALayer?
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        // Drawing code here.
    }
    
    override func mouseDown(theEvent: NSEvent) {
        
        let viewPoint = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        let rootLayerPoint = self.convertPointToLayer(viewPoint)
        if let rootLayer = self.layer {
            let hitLayer = rootLayer.hitTest(rootLayerPoint)
            if hitLayer != rootLayer {
                
                layerSelectedByClick = hitLayer
                let hitPointInHitLayerFrame = rootLayer.convertPoint(rootLayerPoint, toLayer: hitLayer)
                let ax = hitPointInHitLayerFrame.x / NSWidth(hitLayer.bounds)
                let ay = hitPointInHitLayerFrame.y / NSHeight(hitLayer.bounds)
                
                // Pause animations
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                
                // When setting the anchor point we also need to set the position
                hitLayer.anchorPoint = CGPoint(x:ax, y:ay)
                
                println("Hit Layer Anchor Point:")
                println(hitLayer.anchorPoint)
                println("Hit Layer Frame:")
                println(hitLayer.frame)
                println("Hit Layer Bounds:")
                println(hitLayer.bounds)
                println()
                
                let newSuperLayerPosition = rootLayer.convertPoint(rootLayerPoint, toLayer:hitLayer.superlayer)
                hitLayer.position = newSuperLayerPosition
                
                CATransaction.commit()
                
                if let shape = hitLayer as? CAShapeLayer {
                    highlightShapeLayer(shape)
                }
                
            } else {
                layerSelectedByClick = nil
            }
            
            // De-select all other layer that are not contained in the two caches
            let allLayers = Set(rootLayer.sublayers as! [CALayer])
            var cachedLayers = Set(layersSelectedByDrag)
            if layerSelectedByClick != nil {
                cachedLayers.insert(layerSelectedByClick!)
            }
            
            let layersNeedingDeselection = allLayers.subtract(cachedLayers)
            for layer in layersNeedingDeselection {
                if let shape = layer as? CAShapeLayer {
                    removeHighlightOnShapeLater(shape)
                }
            }
        }
        

    }
    
    override func mouseDragged(theEvent: NSEvent) {
        
        if let layerSelectedByClick = layerSelectedByClick, rootLayer = self.layer {
            
            
            let viewPoint = self.convertPoint(theEvent.locationInWindow, fromView: nil)
            let rootLayerPoint = self.convertPointToLayer(viewPoint)
            let newSuperLayerPosition = rootLayer.convertPoint(rootLayerPoint, toLayer:layerSelectedByClick.superlayer)
            let offset = CGPoint(x: newSuperLayerPosition.x - layerSelectedByClick.position.x,
                                 y: newSuperLayerPosition.y - layerSelectedByClick.position.y)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
                // Update the position of the layer being dragged position of 
                // any layers that are selected because of a previous drag selection box
                layerSelectedByClick.position = newSuperLayerPosition
                for layer in layersSelectedByDrag {
                    layer.position = CGPoint(x: layer.position.x + offset.x, y: layer.position.y + offset.y)
                }
            
            CATransaction.commit()
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        
        // Clear all selection because the background was clicked during this event
        if layerSelectedByClick == nil {
            
            for layer in layersSelectedByDrag {
                if let shape = layer as? CAShapeLayer {
                    removeHighlightOnShapeLater(shape)
                }
            }
            layersSelectedByDrag.removeAll(keepCapacity: true)
        }
    }
}
