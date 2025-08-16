import asyncio
from dataclasses import field
from typing import Any, Optional

import flet as ft

__all__ = ["FletServiceExtension"]


@ft.control("FletServiceExtension")
class FletServiceExtension(ft.Service):
    """
    A template service extension that demonstrates how to create advanced Flet services
    with event handlers, method invocation, and state management.

    This is an educational template showing how to:
    - Handle events from the Flutter side
    - Trigger events to the Python side
    - Manage service state
    - Implement async method calls
    - Use configuration parameters

    Note:
        This control is non-visual and should be added to
            [`Page.services`][flet.Page.services] list before it can be used.
    """

    # Configuration properties
    auto_start: bool = field(default=False)
    """
    Whether the service should start automatically when initialized.
    """

    interval: float = field(default=1.0)
    """
    The interval in seconds for periodic operations.
    """

    max_count: int = field(default=10)
    """
    Maximum count for demonstration purposes.
    """

    # Event handlers
    on_status_change: Optional[ft.EventHandler] = None
    """
    Event handler called when the service status changes.
    Event data contains: {"status": "started|stopped|paused", "timestamp": float}
    """

    on_counter_update: Optional[ft.EventHandler] = None
    """
    Event handler called when the internal counter updates.
    Event data contains: {"count": int, "message": str}
    """

    on_error: Optional[ft.EventHandler] = None
    """
    Event handler called when an error occurs.
    Event data contains: {"error": str, "code": int}
    """

    # Async methods for service control
    async def start_service_async(
        self, custom_interval: Optional[float] = None, timeout: Optional[float] = 10
    ) -> bool:
        """
        Starts the service with optional custom interval.

        Args:
            custom_interval: Custom interval to override the default.
            timeout: Maximum time to wait for response.

        Returns:
            True if service started successfully, False otherwise.
        """
        return await self._invoke_method(
            method_name="start_service",
            arguments={
                "interval": custom_interval
                if custom_interval is not None
                else self.interval
            },
            timeout=timeout,
        )

    async def stop_service_async(self, timeout: Optional[float] = 10) -> bool:
        """
        Stops the service.

        Args:
            timeout: Maximum time to wait for response.

        Returns:
            True if service stopped successfully, False otherwise.
        """
        return await self._invoke_method(method_name="stop_service", timeout=timeout)

    async def pause_service_async(self, timeout: Optional[float] = 10) -> bool:
        """
        Pauses the service.

        Args:
            timeout: Maximum time to wait for response.

        Returns:
            True if service paused successfully, False otherwise.
        """
        return await self._invoke_method(method_name="pause_service", timeout=timeout)

    async def get_status_async(self, timeout: Optional[float] = 10) -> dict[str, Any]:
        """
        Gets the current service status.

        Args:
            timeout: Maximum time to wait for response.

        Returns:
            Dictionary containing status information.
        """
        return await self._invoke_method(method_name="get_status", timeout=timeout)

    async def get_counter_async(self, timeout: Optional[float] = 10) -> int:
        """
        Gets the current counter value.

        Args:
            timeout: Maximum time to wait for response.

        Returns:
            Current counter value.
        """
        return await self._invoke_method(method_name="get_counter", timeout=timeout)

    async def reset_counter_async(self, timeout: Optional[float] = 10) -> bool:
        """
        Resets the counter to zero.

        Args:
            timeout: Maximum time to wait for response.

        Returns:
            True if counter was reset successfully.
        """
        return await self._invoke_method(method_name="reset_counter", timeout=timeout)

    async def set_configuration_async(
        self,
        interval: Optional[float] = None,
        max_count: Optional[int] = None,
        timeout: Optional[float] = 10,
    ) -> bool:
        """
        Updates the service configuration.

        Args:
            interval: New interval value.
            max_count: New maximum count value.
            timeout: Maximum time to wait for response.

        Returns:
            True if configuration was updated successfully.
        """
        config = {}
        if interval is not None:
            config["interval"] = interval
        if max_count is not None:
            config["max_count"] = max_count

        return await self._invoke_method(
            method_name="set_configuration", arguments=config, timeout=timeout
        )

    async def trigger_custom_event_async(
        self, event_name: str, data: dict[str, Any], timeout: Optional[float] = 10
    ) -> bool:
        """
        Triggers a custom event for demonstration purposes.

        Args:
            event_name: Name of the event to trigger.
            data: Event data to send.
            timeout: Maximum time to wait for response.

        Returns:
            True if event was triggered successfully.
        """
        return await self._invoke_method(
            method_name="trigger_custom_event",
            arguments={"event_name": event_name, "data": data},
            timeout=timeout,
        )

    # Synchronous convenience methods
    def start_service(
        self, custom_interval: Optional[float] = None, timeout: Optional[float] = 10
    ):
        """
        Starts the service (synchronous version).
        """
        asyncio.create_task(self.start_service_async(custom_interval, timeout))

    def stop_service(self, timeout: Optional[float] = 10):
        """
        Stops the service (synchronous version).
        """
        asyncio.create_task(self.stop_service_async(timeout))

    def pause_service(self, timeout: Optional[float] = 10):
        """
        Pauses the service (synchronous version).
        """
        asyncio.create_task(self.pause_service_async(timeout))

    def reset_counter(self, timeout: Optional[float] = 10):
        """
        Resets the counter (synchronous version).
        """
        asyncio.create_task(self.reset_counter_async(timeout))
