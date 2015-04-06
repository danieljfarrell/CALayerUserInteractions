//
//  CanvasView.swift
//  UserInteractionWithLayers
//
//  Created by Daniel Farrell on 06/04/2015.
//  Copyright (c) 2015 Daniel Farrell. All rights reserved.
//

import Cocoa

class CanvasView : NSView {

    /* State for selected items */
    var selectedLayers : Set<CALayer> = Set()
    var layerSelectedOnMouseDown : CALayer?
    var didDrag : Bool = false
    var didAddNewLayerOnMouseDown = false
    
    
    /** Stores the layer in cache and update the layer properties so that it draws a border */
    func addLayerToSelectedCache( layer : CALayer) {
        self.selectedLayers.insert(layer)
        layer.borderWidth = 4.0
        layer.borderColor = NSColor.alternateSelectedControlColor().CGColor
    }
    
    func removeLayerFromSelectedCache(layer : CALayer) {
        layer.borderWidth = 0.0
        layer.borderColor = nil
        self.selectedLayers.remove(layer)
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
        
        // Reset state
        didDrag = false
        didAddNewLayerOnMouseDown = false
        layerSelectedOnMouseDown = nil
        
        // Convert to layer coordinate system
        let viewPoint = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        let rootLayerPoint = self.convertPointToLayer(viewPoint)
        if let rootLayer = self.layer {
            
            let hitLayer = rootLayer.hitTest(rootLayerPoint)
            if hitLayer != rootLayer {
            
                // Store hit layer
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
                
                // Perform actions that need to occur at mouseDown time
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
        
        // If nothing hit the reset all state
        if layerSelectedOnMouseDown ==  nil {
            removeAllLayersFromSelectedCache()
        }
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        
        // Update state
        didDrag = true
        
        // If we have something to drag, drag it!
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
