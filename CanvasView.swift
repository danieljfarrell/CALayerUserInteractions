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

func removeHighlightOnShapeLayer(shape : CAShapeLayer) {
    shape.lineWidth = 0.0
}

func updateLayerPropertyWithoutAnimations( layer: CALayer, process : (layer : CALayer) -> () ) {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    process(layer: layer)
    CATransaction.commit()
}


class CanvasView: NSView {

    var selectedLayers : Set<CALayer> = Set()
    var layerSelectedOnMouseDown : CALayer?
    var didDrag : Bool = false
    var didAddNewLayerOnMouseDown = false
    
    func addLayerToSelectedCache( layer : CALayer) {
        self.selectedLayers.insert(layer)
        if let shape = layer as? CAShapeLayer {
            highlightShapeLayer(shape)
        }
    }
    
    func removeLayerFromSelectedCache(layer : CALayer) {
        if let shape = layer as? CAShapeLayer {
            removeHighlightOnShapeLayer(shape)
            self.selectedLayers.remove(shape)
        }
    }
    
    func removeAllLayersFromSelectedCache() {
        for layer in selectedLayers {
            if let shape = layer as? CAShapeLayer {
                removeLayerFromSelectedCache(shape)
            }
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        // Drawing code here.
    }
    
    override func mouseDown(theEvent: NSEvent) {
        
        didDrag = false
        didAddNewLayerOnMouseDown = false
        let viewPoint = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        let rootLayerPoint = self.convertPointToLayer(viewPoint)
        layerSelectedOnMouseDown = nil
        if let rootLayer = self.layer {
            let hitLayer = rootLayer.hitTest(rootLayerPoint)
            if hitLayer != rootLayer {
            
                layerSelectedOnMouseDown = hitLayer
                let hitPointInHitLayerFrame = rootLayer.convertPoint(rootLayerPoint, toLayer: hitLayer)
                let ax = hitPointInHitLayerFrame.x / NSWidth(hitLayer.bounds)
                let ay = hitPointInHitLayerFrame.y / NSHeight(hitLayer.bounds)
                
                // Pause animations
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                
                // When setting the anchor point we also need to set the position
                hitLayer.anchorPoint = CGPoint(x:ax, y:ay)
                let newSuperLayerPosition = rootLayer.convertPoint(rootLayerPoint, toLayer:hitLayer.superlayer)
                hitLayer.position = newSuperLayerPosition
                
                CATransaction.commit()
                
                let shiftIsPressed = !((theEvent.modifierFlags & NSEventModifierFlags.ShiftKeyMask).rawValue == 0)
                let cacheContainsHitLayer = selectedLayers.contains(hitLayer)

                
                if !cacheContainsHitLayer {
                    
                    if !shiftIsPressed {
                        // De-select all layers and select the clicked layer
                        // which is outside the current selection group.
                        for layer in selectedLayers {
                            if let shape = layer as? CAShapeLayer {
                                removeLayerFromSelectedCache(shape)
                            }
                        }
                        addLayerToSelectedCache(hitLayer)
                        didAddNewLayerOnMouseDown = true
                    } else {
                        addLayerToSelectedCache(hitLayer)
                        didAddNewLayerOnMouseDown = true
                    }
                }
            }
        }
        
        if layerSelectedOnMouseDown ==  nil {
            removeAllLayersFromSelectedCache()
        }
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        
        didDrag = true
        
        if let layerSelectedOnMouseDown = layerSelectedOnMouseDown, rootLayer = self.layer {
            
            
            let viewPoint = self.convertPoint(theEvent.locationInWindow, fromView: nil)
            let rootLayerPoint = self.convertPointToLayer(viewPoint)
            let newSuperLayerPosition = rootLayer.convertPoint(rootLayerPoint, toLayer:layerSelectedOnMouseDown.superlayer)
            let offset = CGPoint(x: newSuperLayerPosition.x - layerSelectedOnMouseDown.position.x,
                                 y: newSuperLayerPosition.y - layerSelectedOnMouseDown.position.y)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
                // Update the position of the layer being dragged position of 
                // any layers that are selected because of a previous drag selection box
                layerSelectedOnMouseDown.position = newSuperLayerPosition
                for layer in selectedLayers.subtract(Set([layerSelectedOnMouseDown])) {
                    layer.position = CGPoint(x: layer.position.x + offset.x, y: layer.position.y + offset.y)
                }
            
            CATransaction.commit()
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        
        // Clear all selection because the background was clicked during this event
        if let layerSelectedOnMouseDown = layerSelectedOnMouseDown {
            
            let shiftIsPressed = !((theEvent.modifierFlags & NSEventModifierFlags.ShiftKeyMask).rawValue == 0)
            let cacheContainsHitLayer = selectedLayers.contains(layerSelectedOnMouseDown)
            
            if shiftIsPressed && !didDrag && !didAddNewLayerOnMouseDown {
                
                // Toggle layer in and out of selected set
                if cacheContainsHitLayer {
                    removeLayerFromSelectedCache(layerSelectedOnMouseDown)
                } else {
                    addLayerToSelectedCache(layerSelectedOnMouseDown)
                }
            }
            
        }
    }
}
