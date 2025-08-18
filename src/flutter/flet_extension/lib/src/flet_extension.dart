import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// A comprehensive Flet extension control demonstrating advanced Flutter integration.
/// 
/// This control serves as a template for creating custom Flet extensions with:
/// - Rich visual customization and Material Design support
/// - Multiple animation types with smooth transitions
/// - Interactive event handling and state management
/// - Professional error handling and debugging support
/// - Clean architecture suitable for developers of all levels
/// 
/// The control communicates with the Python side through method channels
/// and provides real-time updates for dynamic content changes.
class FletExtensionControl extends StatefulWidget {
  /// The Flet control configuration from Python.
  /// 
  /// Contains all properties, styling, and event handlers
  /// defined on the Python side.
  final Control control;

  /// Creates a FletExtension control.
  /// 
  /// The [control] parameter is required and contains all configuration
  /// from the Python side including styling, content, and event handlers.
  const FletExtensionControl({super.key, required this.control});

  @override
  State<FletExtensionControl> createState() => _FletExtensionControlState();
}

/// State management for the FletExtension control.
/// 
/// Handles animation controllers, user interactions, and communication
/// with the Python side through method channels. Provides smooth animations
/// and responsive UI updates while maintaining clean state management.
class _FletExtensionControlState extends State<FletExtensionControl>
    with TickerProviderStateMixin {
  // Animation system
  /// Main animation controller for all animation types.
  /// Duration and curve are configurable from Python side.
  late AnimationController _animationController;
  
  /// Fade animation for opacity transitions (1.0 to 0.0).
  late Animation<double> _fadeAnimation;
  
  /// Scale animation for size transitions (1.0 to 1.2).
  late Animation<double> _scaleAnimation;
  
  /// Slide animation for position transitions (zero to offset).
  late Animation<Offset> _slideAnimation;
  
  /// Rotation animation for 360-degree turns (0.0 to 1.0).
  late Animation<double> _rotateAnimation;
  
  // Interaction state
  /// Tracks whether the control is currently being hovered.
  bool _isHovered = false;
  
  /// Current active animation type ('fade', 'scale', 'slide', 'rotate', or 'none').
  String _currentAnimationType = 'none';

  @override
  void initState() {
    super.initState();
    debugPrint("Extension initState: ${widget.control.id}");
    
    try {
      // Initialize animation controller with default duration
      // Duration can be overridden by custom_animation property
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      
      // Add listener to update state during animation
      _animationController.addListener(() {
        setState(() {
          // This will trigger rebuilds during animation
        });
      });
      
      // Initialize all animation types with smooth default curves
      // These will be reconfigured when animations are triggered
      _initializeAnimations();
      
      // Set up animation completion monitoring
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          // Animation fully completed (including reverse)
          // Trigger completion event before resetting animation type
          if (_currentAnimationType != 'none') {
            _triggerAnimationComplete();
          }
          setState(() {
            _currentAnimationType = 'none';
          });
          debugPrint("Animation fully completed, reset to 'none'");
        } else if (status == AnimationStatus.completed) {
          debugPrint("Animation completed: $_currentAnimationType");
        }
      });
      
      // Register for method calls from Python side
      widget.control.addInvokeMethodListener(_invokeMethod);
      
      debugPrint("Extension initialization completed successfully");
    } catch (e) {
      debugPrint("Error during extension initialization: $e");
      // Continue with basic functionality even if some features fail
    }
  }
  
  /// Initializes all animation objects with default configurations.
  /// 
  /// These animations will be reconfigured with custom curves and durations
  /// when specific animations are triggered from the Python side.
  void _initializeAnimations() {
    const defaultCurve = Curves.easeInOut;
    
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: defaultCurve),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: defaultCurve),
    );
    
    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.1, 0)).animate(
      CurvedAnimation(parent: _animationController, curve: defaultCurve),
    );
    
    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: defaultCurve),
    );
  }

  @override
  void dispose() {
    debugPrint("Extension dispose: ${widget.control.id}");
    try {
      // Clean up animation controller to prevent memory leaks
      _animationController.dispose();
      debugPrint("Animation controller disposed successfully");
    } catch (e) {
      debugPrint("Error during animation controller disposal: $e");
    }
    widget.control.removeInvokeMethodListener(_invokeMethod);
    super.dispose();
  }
  
  /// Handles method calls from the Python side.
  /// 
  /// Supports the following methods:
  /// - `trigger_animation`: Starts an animation with the specified type
  /// - `update_content`: Updates control properties and triggers a rebuild
  /// 
  /// Returns a boolean indicating success, or throws an exception on error.
  Future<dynamic> _invokeMethod(String name, dynamic args) async {
    debugPrint("Extension method invoked: $name with args: $args");
    
    try {
      switch (name) {
        case "trigger_animation":
          final animationType = args?["animation_type"] as String? ?? "fade";
          debugPrint("Triggering animation: $animationType");
          return _triggerAnimation(animationType);
          
        case "update_content":
          debugPrint("Updating content with new properties");
          Map<String, dynamic>? typedArgs;
          if (args != null) {
            typedArgs = Map<String, dynamic>.from(args as Map);
          }
          return _updateContent(typedArgs);
          
        default:
          final errorMsg = "Unknown FletExtension method: $name";
          debugPrint(errorMsg);
          throw Exception(errorMsg);
      }
    } catch (e) {
      final errorMsg = "Error in FletExtension method $name: $e";
      debugPrint(errorMsg);
      rethrow;
    }
  }
  
  /// Retrieves the animation curve from custom_animation property.
  /// 
  /// Returns the curve specified in the custom_animation configuration,
  /// or defaults to [Curves.easeInOut] for smooth animations.
  Curve _getCurveFromAnimation() {
    try {
      final customAnimation = widget.control.getAnimation("custom_animation");
      return customAnimation?.curve ?? Curves.easeInOut;
    } catch (e) {
      debugPrint("Error getting animation curve: $e, using default");
      return Curves.easeInOut;
    }
  }

  /// Triggers an animation of the specified type.
  /// 
  /// Supported animation types:
  /// - 'fade': Opacity transition (visible to transparent and back)
  /// - 'scale': Size transition (normal to 1.2x scale and back)
  /// - 'slide': Position transition (normal to offset and back)
  /// - 'rotate': Rotation transition (0 to 360 degrees and back)
  /// 
  /// The animation uses custom duration and curve if specified in custom_animation,
  /// otherwise defaults to 500ms with easeInOut curve.
  /// 
  /// Returns true if animation started successfully, false otherwise.
  bool _triggerAnimation(String animationType) {
    debugPrint("Starting animation: $animationType");
    
    try {
      // Validate animation type
      const validTypes = ['fade', 'scale', 'slide', 'rotate'];
      if (!validTypes.contains(animationType)) {
        debugPrint("Warning: Unknown animation type '$animationType', using 'fade'");
        animationType = 'fade';
      }
      
      // Reset animation controller to initial state
      _animationController.reset();
      
      // Update current animation type
      setState(() {
        _currentAnimationType = animationType;
      });
      debugPrint("Current animation type set to: $_currentAnimationType");
      
      // Apply custom animation configuration if available
      final customAnimation = widget.control.getAnimation("custom_animation");
      if (customAnimation != null) {
        _animationController.duration = customAnimation.duration;
        debugPrint("Using custom animation duration: ${customAnimation.duration}");
      }
      
      // Get animation curve from configuration
      final animationCurve = _getCurveFromAnimation();
      
      // Reconfigure animations with current settings
      _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _animationController, curve: animationCurve),
      );
      
      _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _animationController, curve: animationCurve),
      );
      
      _slideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.1, 0)).animate(
        CurvedAnimation(parent: _animationController, curve: animationCurve),
      );
      
      _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: animationCurve),
      );
      
      // Execute animation sequence based on type
      switch (animationType) {
        case 'fade':
        case 'scale':
        case 'slide':
        case 'rotate':
          debugPrint("Starting forward animation for: $animationType");
          _animationController.forward().then((_) {
            debugPrint("Forward animation completed for: $animationType, starting reverse");
            _animationController.reverse().then((_) {
              debugPrint("Reverse animation completed for: $animationType");
              // Animation complete event will be triggered by status listener
            });
          });
          break;
        default:
          debugPrint("Starting single direction animation for: $animationType");
          _animationController.forward().then((_) {
            debugPrint("Single direction animation completed for: $animationType");
            // Animation complete event will be triggered by status listener
          });
      }
      
      return true;
    } catch (e) {
      debugPrint("Error triggering animation '$animationType': $e");
      return false;
    }
  }
  
  /// Updates the control's content and properties.
  /// 
  /// Takes a map of property updates from the Python side and applies them
  /// to the control, then triggers a rebuild to reflect the changes.
  /// 
  /// Returns true if the update was successful, false if args were null
  /// or an error occurred.
  bool _updateContent(Map<String, dynamic>? args) {
    if (args == null) {
      debugPrint("Update content called with null arguments");
      return false;
    }
    
    try {
      debugPrint("Updating control properties: ${args.keys.join(', ')}");
      
      // Update control properties with new values
      widget.control.update(args);
      
      // Trigger rebuild to reflect changes
      setState(() {});
      
      debugPrint("Content update completed successfully");
      return true;
    } catch (e) {
      debugPrint("Error updating content: $e");
      return false;
    }
  }

  /// Triggers the animation_complete event to notify the Python side.
  /// 
  /// Sends event data including the animation type and timestamp
  /// when an animation sequence finishes.
  void _triggerAnimationComplete() {
    try {
      // Capture the current animation type before it gets reset
      final completedAnimationType = _currentAnimationType;
      
      final eventData = {
        "animation_type": completedAnimationType,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      };
      
      widget.control.triggerEvent("animation_complete", eventData);
      debugPrint("Animation complete event triggered for: $completedAnimationType");
    } catch (e) {
      debugPrint("Error triggering animation complete event: $e");
    }
  }
  
  /// Handles click events and notifies the Python side.
  /// 
  /// Triggered when the user taps or clicks on the control.
  /// Sends event data including timestamp and click position.
  void _handleClick() {
    try {
      final eventData = {
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "position": "center",
      };
      
      widget.control.triggerEvent("click", eventData);
      debugPrint("Click event triggered");
    } catch (e) {
      debugPrint("Error handling click event: $e");
    }
  }
  
  /// Handles hover events and updates the visual state.
  /// 
  /// Updates the hover state and notifies the Python side when
  /// the mouse enters or exits the control area.
  void _handleHover(bool isHovered) {
    try {
      setState(() {
        _isHovered = isHovered;
      });
      
      final eventData = {
        "is_hovered": isHovered,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      };
      
      widget.control.triggerEvent("hover", eventData);
      debugPrint("Hover event triggered: $isHovered");
    } catch (e) {
      debugPrint("Error handling hover event: $e");
    }
  }

  /// Builds the widget tree for the FletExtension control.
  /// 
  /// Creates a rich, interactive widget with:
  /// - Customizable content (title, main text, subtitle)
  /// - Material Design styling (colors, borders, shadows)
  /// - Smooth animations (fade, scale, slide, rotate)
  /// - Interactive features (hover effects, click handling)
  /// 
  /// All properties are configurable from the Python side and updates
  /// are reflected immediately through setState calls.
  @override
  Widget build(BuildContext context) {
    debugPrint(
        "Extension build: ${widget.control.id} (${widget.control.hashCode})");
    
    try {
      // Extract content properties with safe defaults
      final src = widget.control.getString("src", "flet is good")!;
      final title = widget.control.getString("title");
      final subtitle = widget.control.getString("subtitle");
      
      // Extract visual styling properties
      final backgroundColor = widget.control.getString("background_color");
      final textColor = widget.control.getString("text_color");
      final borderColor = widget.control.getString("border_color");
      final borderWidth = widget.control.getDouble("border_width", 0.0)!;
      final borderRadius = widget.control.getDouble("border_radius", 8.0)!;
      final fontSize = widget.control.getDouble("font_size", 14.0)!;
      final padding = widget.control.getDouble("padding", 16.0)!;
      final elevation = widget.control.getDouble("elevation", 2.0)!;
      final opacity = widget.control.getDouble("opacity", 1.0)!;
      final clickable = widget.control.getBool("clickable", true)!;
      
      debugPrint("Building with animation type: $_currentAnimationType");
    
      // Build content widgets with proper styling
      final List<Widget> contentWidgets = [];
      
      // Add title if provided
      if (title != null && title.isNotEmpty) {
        contentWidgets.add(
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold,
              color: textColor != null ? parseColor(textColor, Theme.of(context)) : null,
            ),
          ),
        );
        contentWidgets.add(const SizedBox(height: 8));
      }
      
      // Add main content (always present)
      contentWidgets.add(
        Text(
          src,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor != null ? parseColor(textColor, Theme.of(context)) : null,
          ),
        ),
      );
      
      // Add subtitle if provided
      if (subtitle != null && subtitle.isNotEmpty) {
        contentWidgets.add(const SizedBox(height: 8));
        contentWidgets.add(
          Text(
            subtitle,
            style: TextStyle(
              fontSize: fontSize - 2,
              fontStyle: FontStyle.italic,
              color: textColor != null 
                  ? parseColor(textColor, Theme.of(context)) 
                  : Colors.grey[600],
            ),
          ),
        );
      }
      
      // Create content column
      Widget content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: contentWidgets,
      );
    
      // Apply current animation type to content
      Widget animatedContent = content;
      switch (_currentAnimationType) {
        case 'fade':
          animatedContent = FadeTransition(
            opacity: _fadeAnimation,
            child: content,
          );
          break;
        case 'scale':
          animatedContent = ScaleTransition(
            scale: _scaleAnimation,
            child: content,
          );
          break;
        case 'slide':
          animatedContent = SlideTransition(
            position: _slideAnimation,
            child: content,
          );
          break;
        case 'rotate':
          animatedContent = RotationTransition(
            turns: _rotateAnimation,
            child: content,
          );
          break;
        default:
          // No animation active, use content as is
          animatedContent = content;
          break;
      }
    
      // Create styled container with Material Design elements
      Widget styledContent = Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: parseColor(backgroundColor, Theme.of(context)),
          border: borderWidth > 0 ? Border.all(
            color: parseColor(borderColor, Theme.of(context)) ?? Colors.grey,
            width: borderWidth,
          ) : null,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: elevation > 0 ? [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: elevation,
              offset: Offset(0, elevation / 2),
            ),
          ] : null,
        ),
        child: animatedContent,
      );
      
      // Apply opacity if less than fully opaque
      if (opacity < 1.0) {
        styledContent = Opacity(
          opacity: opacity.clamp(0.0, 1.0), // Ensure valid opacity range
          child: styledContent,
        );
      }
      
      // Add interactive features if enabled
      if (clickable) {
        styledContent = MouseRegion(
          onEnter: (_) => _handleHover(true),
          onExit: (_) => _handleHover(false),
          child: GestureDetector(
            onTap: _handleClick,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
              child: styledContent,
            ),
          ),
        );
      }
      
      return ConstrainedControl(
        control: widget.control,
        child: styledContent,
      );
      
    } catch (e) {
      debugPrint("Error building FletExtension widget: $e");
      
      // Return a fallback widget in case of errors
      return ConstrainedControl(
        control: widget.control,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.red[50],
            border: Border.all(color: Colors.red, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "Error: Unable to render FletExtension",
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }
}
