from dataclasses import field
from typing import Optional, Any, Callable, Union, List

import flet as ft
from flet import AnimationValue, Animation, AnimationCurve, Duration, DurationValue

__all__ = ["FletExtension"]


@ft.control("FletExtension")
class FletExtension(ft.ConstrainedControl):
    """
    A comprehensive Flet extension control demonstrating advanced features.
    
    This control serves as a template for creating custom Flet extensions with:
    - Rich visual customization options
    - Animation support with multiple types and curves
    - Interactive event handling (click, hover)
    - Dynamic content updates
    - Professional styling capabilities
    
    Suitable for developers of all levels as a learning reference and starting point
    for building custom Flet controls.
    
    Example:
        ```python
        import flet as ft
        from flet_extension import FletExtension
        
        def main(page: ft.Page):
            ext = FletExtension(
                src="Hello, Flet!",
                title="My Extension",
                subtitle="Custom control demo",
                background_color="#e3f2fd",
                text_color="#1976d2",
                border_radius=12,
                elevation=4,
                on_click=lambda e: print("Extension clicked!")
            )
            page.add(ext)
        
        ft.run(main)
        ```
    """

    def __init__(
        self,
        src: Optional[str] = None,
        title: Optional[str] = None,
        subtitle: Optional[str] = None,
        background_color: Optional[str] = None,
        text_color: Optional[str] = None,
        border_radius: Optional[float] = None,
        border_width: Optional[float] = None,
        border_color: Optional[str] = None,
        padding: Optional[Union[int, float, ft.Padding]] = None,
        margin: Optional[Union[int, float, ft.Margin]] = None,
        animation_type: Optional[str] = None,
        animation_duration: Optional[Union[int, float, Duration]] = None,
        animation_curve: Optional[AnimationCurve] = None,
        clickable: Optional[bool] = None,
        elevation: Optional[float] = None,
        opacity: Optional[float] = None,
        on_click: Optional[Callable[[ft.ControlEvent], None]] = None,
        on_hover: Optional[Callable[[ft.ControlEvent], None]] = None,
        on_animation_complete: Optional[Callable[[ft.ControlEvent], None]] = None,
        **kwargs
    ):
        """
        Initialize the FletExtension control.
        
        Args:
            src: Primary content text to display
            title: Title text shown at the top
            subtitle: Subtitle text shown at the bottom
            background_color: Background color (hex, named, or CSS color)
            text_color: Text color for all text elements
            border_radius: Corner radius for rounded borders
            border_width: Width of the border line
            border_color: Color of the border
            padding: Internal spacing around content
            margin: External spacing around the control
            animation_type: Type of animation ('fade', 'scale', 'slide', 'rotate')
            animation_duration: Duration of animations in milliseconds
            animation_curve: Animation easing curve
            clickable: Whether the control responds to clicks
            elevation: Shadow elevation (0-24)
            opacity: Transparency level (0.0-1.0)
            on_click: Callback function for click events
            on_hover: Callback function for hover events
            on_animation_complete: Callback function when animation finishes
            **kwargs: Additional control properties
        """
        super().__init__(**kwargs)
        
        self.src = src
        self.title = title
        self.subtitle = subtitle
        self.background_color = background_color
        self.text_color = text_color
        self.border_radius = border_radius if border_radius is not None else 8.0
        self.border_width = border_width if border_width is not None else 0.0
        self.border_color = border_color
        self.padding = padding if padding is not None else 16.0
        self.margin = margin if margin is not None else 0.0
        self.animation_type = animation_type
        self.animation_duration = animation_duration if animation_duration is not None else 1.0
        self.animation_curve = animation_curve if animation_curve is not None else AnimationCurve.EASE_IN_OUT
        self.clickable = clickable if clickable is not None else True
        self.elevation = elevation if elevation is not None else 2.0
        self.opacity = opacity if opacity is not None else 1.0
        self.on_click = on_click
        self.on_hover = on_hover
        self.on_animation_complete = on_animation_complete
        
        # Initialize animation properties
        self.animation = None
        self.custom_animation = None
        self.font_size = 14.0

    # Content properties
    src: Optional[str] = field(default=None)
    """Primary content text to display in the extension.
    
    This is the main text content that will be prominently displayed.
    Supports plain text and can be updated dynamically.
    """
    
    title: Optional[str] = field(default=None)
    """Title text displayed at the top of the extension.
    
    Used for headings or primary labels. Typically rendered with
    larger font size and bold styling.
    """
    
    subtitle: Optional[str] = field(default=None)
    """Subtitle text displayed at the bottom of the extension.
    
    Used for secondary information, descriptions, or status text.
    Typically rendered with smaller font size.
    """
    
    # Visual properties
    background_color: Optional[str] = field(default=None)
    """Background color of the extension container.
    
    Accepts hex colors (#RRGGBB), named colors (red, blue), or CSS colors.
    Example: '#e3f2fd', 'lightblue', 'rgba(227, 242, 253, 0.8)'
    """
    
    text_color: Optional[str] = field(default=None)
    """Color of all text elements in the extension.
    
    Applied to title, src, and subtitle text. Accepts same formats
    as background_color. Defaults to theme text color if not specified.
    """
    
    border_color: Optional[str] = field(default=None)
    """Color of the border.
    
    Only visible when border_width > 0. Accepts same color formats
    as background_color.
    """
    
    border_width: Optional[float] = field(default=0.0)
    """Width of the border line in logical pixels.
    
    Set to 0 for no border. Typical values range from 1-4 pixels.
    Requires border_color to be visible.
    """
    
    border_radius: Optional[float] = field(default=8.0)
    """Corner radius for rounded borders in logical pixels.
    
    Controls how rounded the corners appear. Common values:
    - 0: Sharp corners
    - 4-8: Slightly rounded
    - 12-16: Moderately rounded
    - 20+: Very rounded
    """
    
    # Size and spacing
    font_size: Optional[float] = field(default=14.0)
    """Font size for text elements in logical pixels.
    
    Applied to the main src text. Title and subtitle may use
    proportionally larger/smaller sizes based on this value.
    """
    
    padding: Optional[float] = field(default=16.0)
    """Internal spacing around the content in logical pixels.
    
    Can be a single number for uniform padding, or ft.Padding object
    for different values per side.
    """
    
    margin: Optional[float] = field(default=0.0)
    """External spacing around the control in logical pixels.
    
    Can be a single number for uniform margin, or ft.Margin object
    for different values per side.
    """
    
    # Animation properties
    animation_duration: Optional[float] = field(default=1.0)
    """Duration of animations in seconds.
    
    Can be a float for seconds. Typical values: 0.2-0.5 for quick animations, 
    1.0-2.0 for slower effects. Used when triggering animations programmatically.
    """
    
    animation_type: Optional[str] = field(default=None)
    """Type of animation to apply when triggered.
    
    Supported animation types:
    - 'fade': Fade in/out effect
    - 'scale': Scale up/down effect
    - 'slide': Slide in/out effect
    - 'rotate': Rotation effect
    
    Use trigger_animation() or trigger_animation_async() to start animations.
    """
    
    animation: Optional[AnimationValue] = field(default=None)
    """Flet native animation configuration using AnimationValue.
    
    For advanced animation control. If specified, overrides
    animation_duration and animation_curve settings.
    """
    
    custom_animation: Optional[AnimationValue] = field(default=None)
    """Custom animation configuration using Flet's Animation class.
    
    Can be used alongside the main animation for layered effects.
    Allows fine-grained control over animation timing and curves.
    """
    
    animation_curve: Optional[AnimationCurve] = field(default=AnimationCurve.EASE_IN_OUT)
    """Animation easing curve for smooth transitions.
    
    Common curves:
    - EASE_IN_OUT: Smooth start and end (default)
    - LINEAR: Constant speed
    - EASE_IN: Slow start, fast end
    - EASE_OUT: Fast start, slow end
    - BOUNCE_IN/OUT: Bouncing effect
    """
    
    # Interactive properties
    clickable: Optional[bool] = field(default=True)
    """Whether the extension responds to click events.
    
    When True, the control will:
    - Show hover effects
    - Trigger on_click events when clicked
    - Display appropriate cursor on hover
    """
    
    elevation: Optional[float] = field(default=2.0)
    """Material Design shadow elevation (0-24).
    
    Controls the depth appearance of the control:
    - 0: No shadow (flat)
    - 1-4: Subtle shadow
    - 6-12: Moderate shadow
    - 16-24: Strong shadow (use sparingly)
    """
    
    opacity: Optional[float] = field(default=1.0)
    """Transparency level of the entire control (0.0 to 1.0).
    
    - 0.0: Completely transparent (invisible)
    - 0.5: Semi-transparent
    - 1.0: Completely opaque (default)
    
    Useful for fade effects or disabled states.
    """
    
    # Event handlers
    on_click: Optional[Callable[[ft.ControlEvent], None]] = field(default=None)
    """Callback function triggered when the control is clicked.
    
    Args:
        e (ft.ControlEvent): Event object containing click information
        
    Example:
        ```python
        def handle_click(e):
            print(f"Extension clicked! Control: {e.control}")
            e.control.src = "Clicked!"
            e.control.update()
            
        ext = FletExtension(on_click=handle_click)
        ```
    """
    
    on_hover: Optional[Callable[[ft.ControlEvent], None]] = field(default=None)
    """Callback function triggered when mouse enters/exits the control.
    
    Args:
        e (ft.ControlEvent): Event object with hover information
        
    Note:
        The event data contains information about hover state.
        Use e.data to determine if mouse entered ("true") or exited ("false").
        
    Example:
        ```python
        def handle_hover(e):
            if e.data == "true":
                e.control.elevation = 8
            else:
                e.control.elevation = 2
            e.control.update()
            
        ext = FletExtension(on_hover=handle_hover)
        ```
    """
    
    on_animation_complete: Optional[Callable[[ft.ControlEvent], None]] = field(default=None)
    """Callback function triggered when an animation finishes.
    
    Args:
        e (ft.ControlEvent): Event object containing animation completion info
        
    This is useful for chaining animations or updating UI state
    after an animation completes.
    
    Example:
        ```python
        def handle_animation_done(e):
            print("Animation completed!")
            e.control.src = "Animation finished"
            e.control.update()
            
        ext = FletExtension(on_animation_complete=handle_animation_done)
        ```
    """
    
    # Methods for triggering events from Python
    async def trigger_animation_async(self, animation_type: str = "fade", custom_animation: Optional[AnimationValue] = None):
        """
        Trigger an animation asynchronously on the Flutter side.
        
        This method communicates with the Flutter control to start an animation.
        The animation will use the control's current animation_duration and
        animation_curve settings.
        
        Args:
            animation_type: Type of animation to trigger
                - 'fade': Fade in/out effect
                - 'scale': Scale up/down effect  
                - 'slide': Slide in/out effect
                - 'rotate': Rotation effect
            custom_animation: Optional custom animation configuration
                
        Raises:
            ValueError: If animation_type is not supported
            
        Example:
            ```python
            # Trigger a scale animation
            await ext.trigger_animation_async("scale")
            
            # Trigger with custom duration
            ext.animation_duration = 0.5
            await ext.trigger_animation_async("fade")
            ```
        """
        valid_types = ["fade", "scale", "slide", "rotate"]
        if animation_type not in valid_types:
            raise ValueError(f"Invalid animation_type '{animation_type}'. Must be one of: {valid_types}")
            
        # Use provided custom_animation or create default
        if custom_animation is None:
            custom_animation = Animation(
                duration=Duration(milliseconds=int(self.animation_duration * 1000)),
                curve=self.animation_curve or AnimationCurve.EASE_IN_OUT
            )
        
        # Set the custom_animation property
        self.custom_animation = custom_animation
        
        try:
            return await self._invoke_method(
                "trigger_animation",
                {
                    "animation_type": animation_type
                }
            )
        except Exception as e:
            print(f"Debug: Failed to trigger animation '{animation_type}': {e}")
            raise
    
    async def update_content_async(self, src: str = None, title: str = None, subtitle: str = None):
        """
        Update content dynamically and asynchronously.
        
        This method updates the content properties and refreshes the control
        to reflect the changes immediately.
        
        Args:
            src: New main content text to display
            title: New title text (optional)
            subtitle: New subtitle text (optional)
            
        Example:
            ```python
            # Update all content
            await ext.update_content_async(
                src="New content!",
                title="Updated Title",
                subtitle="Updated subtitle"
            )
            
            # Update only main content
            await ext.update_content_async(src="Just new content")
            ```
        """
        # Update local properties if provided
        if src is not None:
            self.src = str(src)
        if title is not None:
            self.title = str(title)
        if subtitle is not None:
            self.subtitle = str(subtitle)
            
        try:
            return await self._invoke_method(
                "update_content",
                {
                    "src": src,
                    "title": title,
                    "subtitle": subtitle
                }
            )
        except Exception as e:
            print(f"Debug: Failed to update content: {e}")
            raise
    

    
    def trigger_animation(self, animation_type: str = "fade", custom_animation: Optional[AnimationValue] = None):
        """
        Trigger an animation synchronously on the Flutter side.
        
        This is the synchronous version of trigger_animation_async().
        Use this when you don't need to await the animation trigger.
        
        Args:
            animation_type: Type of animation to trigger
                - 'fade': Fade in/out effect
                - 'scale': Scale up/down effect
                - 'slide': Slide in/out effect
                - 'rotate': Rotation effect
            custom_animation: Optional custom animation configuration
                
        Raises:
            ValueError: If animation_type is not supported
            
        Example:
            ```python
            # Trigger animation in event handler
            def on_button_click(e):
                ext.trigger_animation("scale")
                
            # Trigger multiple animations
            ext.trigger_animation("fade")
            time.sleep(1)  # Wait for animation
            ext.trigger_animation("scale")
            ```
        """
        valid_types = ["fade", "scale", "slide", "rotate"]
        if animation_type not in valid_types:
            raise ValueError(f"Invalid animation_type '{animation_type}'. Must be one of: {valid_types}")
            
        # Use provided custom_animation or create default
        if custom_animation is None:
            custom_animation = Animation(
                duration=Duration(milliseconds=int(self.animation_duration * 1000)),
                curve=self.animation_curve or AnimationCurve.EASE_IN_OUT
            )
        
        # Set the custom_animation property
        self.custom_animation = custom_animation
        
        try:
            self._invoke_method(
                "trigger_animation",
                {
                    "animation_type": animation_type
                }
            )
        except Exception as e:
            print(f"Debug: Failed to trigger animation '{animation_type}': {e}")
            raise
    
    def update_content(self, src: str = None, title: str = None, subtitle: str = None):
        """
        Update content dynamically (sync version).
        
        This is the synchronous version of update_content_async().
        The control will be updated immediately to reflect the changes.
        
        Args:
            src: New main content text to display (optional)
            title: New title text (optional)
            subtitle: New subtitle text (optional)
            
        Example:
            ```python
            # Update all content in event handler
            def on_button_click(e):
                ext.update_content(
                    src="Button clicked!",
                    title="Updated",
                    subtitle="Status changed"
                )
                
            # Update only main content
            ext.update_content(src="New content only")
            ```
        """
        # Update local properties if provided
        if src is not None:
            self.src = str(src)
        if title is not None:
            self.title = str(title)
        if subtitle is not None:
            self.subtitle = str(subtitle)
            
        try:
            self._invoke_method(
                "update_content",
                {
                    "src": src,
                    "title": title,
                    "subtitle": subtitle
                }
            )
        except Exception as e:
            print(f"Debug: Failed to update content: {e}")
            raise
