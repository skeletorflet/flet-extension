import 'dart:async';
import 'dart:math';

import 'package:flet/flet.dart';
import 'package:flutter/widgets.dart';

/// A comprehensive Flet service extension demonstrating advanced service capabilities.
/// 
/// This service provides a template for creating custom Flet services with:
/// - Asynchronous method invocation from Python
/// - Event-driven communication between Flutter and Python
/// - State management and lifecycle handling
/// - Timer-based operations and periodic tasks
/// - Configuration management and runtime updates
/// - Error handling and debugging support
/// 
/// The service demonstrates common patterns for:
/// - Background processing and periodic operations
/// - Real-time data updates and progress tracking
/// - Service control (start, stop, pause, resume)
/// - Custom event triggering and data exchange
/// - Resource cleanup and proper disposal
/// 
/// Example usage from Python:
/// ```python
/// service = FletServiceExtension(
///     auto_start=True,
///     interval=2.0,
///     max_count=20,
///     on_status_change=handle_status,
///     on_counter_update=handle_counter
/// )
/// page.services.append(service)
/// ```
class FletServiceExtensionService extends FletService {
  /// Creates a new FletServiceExtensionService instance.
  /// 
  /// Args:
  ///   control: The control instance that manages this service
  FletServiceExtensionService({required super.control});

  // Service state management
  /// Whether the service is currently running
  bool _isRunning = false;
  
  /// Whether the service is paused (running but timer stopped)
  bool _isPaused = false;
  
  /// Current counter value for demonstration purposes
  int _counter = 0;
  
  /// Interval between timer ticks in seconds
  double _interval = 1.0;
  
  /// Maximum count before auto-stopping the service
  int _maxCount = 10;
  
  /// Timer instance for periodic operations
  Timer? _timer;
  
  /// Service start timestamp for uptime calculation
  DateTime? _startTime;

  @override
  void init() {
    try {
      super.init();
      debugPrint("FletServiceExtension.init($hashCode) - Initializing service");
      
      // Add the method listener to handle calls from Python
      control.addInvokeMethodListener(_invokeMethod);
      
      // Initialize configuration from control properties with validation
      _initializeConfiguration();
      
      // Auto-start if configured
      final bool autoStart = control.getBool("auto_start", false)!;
      if (autoStart) {
        debugPrint("FletServiceExtension.init - Auto-starting service with interval: $_interval");
        _startService(_interval);
      }
      
      // Trigger initial status
      _triggerStatusChange("initialized");
      debugPrint("FletServiceExtension.init - Service initialized successfully");
    } catch (e) {
      debugPrint("FletServiceExtension.init - Error during initialization: $e");
      _triggerError("Service initialization failed: $e", 500);
      rethrow;
    }
  }
  
  /// Initializes service configuration from control properties.
  /// 
  /// Validates and sets default values for interval and max_count.
  void _initializeConfiguration() {
    try {
      // Get and validate interval
      final double? intervalValue = control.getDouble("interval", 1.0);
      _interval = (intervalValue != null && intervalValue > 0) ? intervalValue : 1.0;
      
      // Get and validate max_count
      final int? maxCountValue = control.getInt("max_count", 10);
      _maxCount = (maxCountValue != null && maxCountValue > 0) ? maxCountValue : 10;
      
      debugPrint("FletServiceExtension._initializeConfiguration - Interval: $_interval, Max count: $_maxCount");
    } catch (e) {
      debugPrint("FletServiceExtension._initializeConfiguration - Error: $e");
      // Use safe defaults
      _interval = 1.0;
      _maxCount = 10;
    }
  }

  /// Handles method invocations from Python side.
  /// 
  /// This is the main entry point for all Python-to-Flutter communication.
  /// Supports the following methods:
  /// - start_service: Starts the service with optional interval
  /// - stop_service: Stops the service and cleans up resources
  /// - pause_service: Pauses the service (keeps state but stops timer)
  /// - get_status: Returns current service status information
  /// - get_counter: Returns current counter value
  /// - reset_counter: Resets counter to zero
  /// - set_configuration: Updates service configuration
  /// - trigger_custom_event: Triggers a custom event with data
  /// 
  /// Args:
  ///   name: The method name to invoke
  ///   args: Arguments for the method call
  /// 
  /// Returns:
  ///   The result of the method invocation
  /// 
  /// Throws:
  ///   Exception: If the method is unknown or execution fails
  Future<dynamic> _invokeMethod(String name, dynamic args) async {
    try {
      debugPrint("FletServiceExtension._invokeMethod: $name with args: $args");
      
      switch (name) {
        case "start_service":
          final double interval = args?["interval"]?.toDouble() ?? _interval;
          return await _startService(interval);
          
        case "stop_service":
          return await _stopService();
          
        case "pause_service":
          return await _pauseService();
          
        case "get_status":
          return _getStatus();
          
        case "get_counter":
          return _counter;
          
        case "reset_counter":
          return _resetCounter();
          
        case "set_configuration":
          return await _setConfiguration(args != null ? Map<String, dynamic>.from(args) : null);
          
        case "trigger_custom_event":
          return _triggerCustomEvent(args != null ? Map<String, dynamic>.from(args) : null);
          
        default:
          final String errorMsg = "Unknown FletServiceExtension method: $name";
          debugPrint("FletServiceExtension._invokeMethod - $errorMsg");
          _triggerError(errorMsg, 404);
          throw Exception(errorMsg);
      }
    } catch (e) {
      final String errorMsg = "Error executing method '$name': $e";
      debugPrint("FletServiceExtension._invokeMethod - $errorMsg");
      _triggerError(errorMsg, 500);
      rethrow;
    }
  }

  // Service control methods
  
  /// Starts the service with the specified interval.
  /// 
  /// Args:
  ///   interval: Timer interval in seconds (must be positive)
  /// 
  /// Returns:
  ///   true if service started successfully, false if already running
  /// 
  /// Throws:
  ///   ArgumentError: If interval is not positive
  Future<bool> _startService(double interval) async {
    try {
      if (_isRunning && !_isPaused) {
        debugPrint("FletServiceExtension._startService - Service is already running");
        return false; // Already running
      }
      
      // Validate interval
      if (interval <= 0) {
        throw ArgumentError("Interval must be positive, got: $interval");
      }
      
      _interval = interval;
      _isRunning = true;
      _isPaused = false;
      _startTime = DateTime.now();
      
      // Start the periodic timer with validated interval
      final int intervalMs = (interval * 1000).round();
      _timer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
        _onTimerTick();
      });
      
      debugPrint("FletServiceExtension._startService - Service started with interval: ${interval}s");
      _triggerStatusChange("started");
      return true;
    } catch (e) {
      final String errorMsg = "Failed to start service: $e";
      debugPrint("FletServiceExtension._startService - $errorMsg");
      _triggerError(errorMsg, 500);
      rethrow;
    }
  }
  
  /// Stops the service and cleans up resources.
  /// 
  /// Returns:
  ///   true if service stopped successfully, false if not running
  Future<bool> _stopService() async {
    try {
      if (!_isRunning) {
        debugPrint("FletServiceExtension._stopService - Service is not running");
        return false; // Not running
      }
      
      // Clean up timer
      _timer?.cancel();
      _timer = null;
      _isRunning = false;
      _isPaused = false;
      
      debugPrint("FletServiceExtension._stopService - Service stopped successfully");
      _triggerStatusChange("stopped");
      return true;
    } catch (e) {
      final String errorMsg = "Failed to stop service: $e";
      debugPrint("FletServiceExtension._stopService - $errorMsg");
      _triggerError(errorMsg, 500);
      rethrow;
    }
  }
  
  /// Toggles the pause state of the service.
  /// 
  /// If running, pauses the service (timer continues but ticks are ignored).
  /// If paused, resumes the service.
  /// 
  /// Returns:
  ///   true if pause state changed successfully, false if service not running
  Future<bool> _pauseService() async {
    try {
      if (!_isRunning || _isPaused) {
        debugPrint("FletServiceExtension._pauseService - Service is not running or already paused");
        return false; // Not running or already paused
      }
      
      _timer?.cancel();
      _timer = null;
      _isPaused = true;
      
      debugPrint("FletServiceExtension._pauseService - Service paused");
      _triggerStatusChange("paused");
      return true;
    } catch (e) {
      final String errorMsg = "Failed to pause service: $e";
      debugPrint("FletServiceExtension._pauseService - $errorMsg");
      _triggerError(errorMsg, 500);
      rethrow;
    }
  }
  
  /// Returns comprehensive status information about the service.
  /// 
  /// Returns:
  ///   A map containing current service state and configuration
  Map<String, dynamic> _getStatus() {
    try {
      final DateTime now = DateTime.now();
      final int? startTimeMs = _startTime?.millisecondsSinceEpoch;
      final int uptimeSeconds = _startTime != null ? now.difference(_startTime!).inSeconds : 0;
      
      return {
        "is_running": _isRunning,
        "is_paused": _isPaused,
        "counter": _counter,
        "interval": _interval,
        "max_count": _maxCount,
        "start_time": startTimeMs,
        "uptime_seconds": uptimeSeconds,
        "progress": _maxCount > 0 ? (_counter / _maxCount).clamp(0.0, 1.0) : 0.0,
        "timestamp": now.millisecondsSinceEpoch,
      };
    } catch (e) {
      debugPrint("FletServiceExtension._getStatus - Error getting status: $e");
      // Return minimal safe status
      return {
        "is_running": false,
        "is_paused": false,
        "counter": 0,
        "error": "Failed to get status: $e",
      };
    }
  }
  
  /// Resets the counter to zero.
  /// 
  /// Returns:
  ///   true if counter reset successfully
  bool _resetCounter() {
    try {
      final int previousCounter = _counter;
      _counter = 0;
      
      debugPrint("FletServiceExtension._resetCounter - Counter reset from $previousCounter to 0");
      _triggerCounterUpdate("Counter reset from $previousCounter to 0");
      return true;
    } catch (e) {
      final String errorMsg = "Failed to reset counter: $e";
      debugPrint("FletServiceExtension._resetCounter - $errorMsg");
      _triggerError(errorMsg, 500);
      return false;
    }
  }
  
  /// Updates service configuration with validation.
  /// 
  /// Args:
  ///   config: Configuration map with optional 'interval' and 'max_count' keys
  /// 
  /// Returns:
  ///   true if configuration was updated, false otherwise
  /// 
  /// Throws:
  ///   ArgumentError: If configuration values are invalid
  Future<bool> _setConfiguration(Map<String, dynamic>? config) async {
    try {
      if (config == null || config.isEmpty) {
        debugPrint("FletServiceExtension._setConfiguration - No configuration provided");
        return false;
      }
      
      bool changed = false;
      final Map<String, dynamic> oldConfig = {
        "interval": _interval,
        "max_count": _maxCount,
      };
      
      // Update interval with validation
      if (config.containsKey("interval")) {
        final double? newInterval = config["interval"]?.toDouble();
        if (newInterval != null) {
          if (newInterval <= 0) {
            throw ArgumentError("Interval must be positive, got: $newInterval");
          }
          
          if (newInterval != _interval) {
            _interval = newInterval;
            changed = true;
            
            // Restart timer if running with new interval
            if (_isRunning && !_isPaused) {
              _timer?.cancel();
              final int intervalMs = (_interval * 1000).round();
              _timer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
                _onTimerTick();
              });
              debugPrint("FletServiceExtension._setConfiguration - Timer restarted with new interval: $_interval");
            }
          }
        }
      }
      
      // Update max_count with validation
      if (config.containsKey("max_count")) {
        final int? newMaxCount = config["max_count"]?.toInt();
        if (newMaxCount != null) {
          if (newMaxCount <= 0) {
            throw ArgumentError("Max count must be positive, got: $newMaxCount");
          }
          
          if (newMaxCount != _maxCount) {
            _maxCount = newMaxCount;
            changed = true;
          }
        }
      }
      
      if (changed) {
        debugPrint("FletServiceExtension._setConfiguration - Configuration updated: $oldConfig -> {interval: $_interval, max_count: $_maxCount}");
        _triggerStatusChange("configuration_updated");
      }
      
      return changed;
    } catch (e) {
      final String errorMsg = "Failed to set configuration: $e";
      debugPrint("FletServiceExtension._setConfiguration - $errorMsg");
      _triggerError(errorMsg, 500);
      rethrow;
    }
  }
  
  /// Triggers a custom event with enhanced metadata.
  /// 
  /// Args:
  ///   args: Arguments containing 'event_name' and 'data' keys
  /// 
  /// Returns:
  ///   true if event triggered successfully
  bool _triggerCustomEvent(Map<String, dynamic>? args) {
    try {
      if (args == null) {
        debugPrint("FletServiceExtension._triggerCustomEvent - No arguments provided");
        return false;
      }
      
      final String eventName = args["event_name"] ?? "custom_event";
      
      // Validate event name
      if (eventName.isEmpty) {
        throw ArgumentError("Event name cannot be empty");
      }
      
      // Create enhanced event data with metadata
      final Map<String, dynamic> data = Map<String, dynamic>.from(args["data"] ?? {});
      data.addAll({
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "service_status": _isRunning ? (_isPaused ? "paused" : "running") : "stopped",
        "counter": _counter,
        "service_uptime": _startTime != null ? DateTime.now().difference(_startTime!).inSeconds : 0,
        "event_source": "FletServiceExtension",
      });
      
      debugPrint("FletServiceExtension._triggerCustomEvent - Triggering event '$eventName' with data: $data");
      
      // Trigger the custom event
      control.triggerEvent(eventName, data);
      return true;
    } catch (e) {
      final String errorMsg = "Failed to trigger custom event: $e";
      debugPrint("FletServiceExtension._triggerCustomEvent - $errorMsg");
      _triggerError(errorMsg, 500);
      return false;
    }
  }

  /// Timer callback executed on each tick.
  /// 
  /// Handles counter increment, progress tracking, and automatic service completion.
  /// Also demonstrates error simulation for testing purposes.
  void _onTimerTick() {
    try {
      // Check if service should continue running
      if (!_isRunning || _isPaused) {
        debugPrint("FletServiceExtension._onTimerTick - Service not active (running: $_isRunning, paused: $_isPaused)");
        return;
      }
      
      _counter++;
      
      // Generate demo data with timestamp
      final DateTime now = DateTime.now();
      String message = "Tick #$_counter at ${now.toIso8601String()}";
      
      // Add special markers for demonstration
      if (_counter % 3 == 0) {
        message += " (Special tick!)";
      }
      
      // Trigger counter update event
      _triggerCounterUpdate(message);
      
      // Check if we've reached max count and auto-complete
      if (_counter >= _maxCount) {
        debugPrint("FletServiceExtension._onTimerTick - Max count reached ($_counter/$_maxCount), stopping service");
        _stopService();
        _triggerStatusChange("completed");
        return;
      }
      
      // Simulate occasional errors for demonstration (every 7th tick with 50% chance)
      if (_counter % 7 == 0 && Random().nextBool()) {
        final String errorMsg = "Simulated error at count $_counter";
        debugPrint("FletServiceExtension._onTimerTick - $errorMsg");
        _triggerError(errorMsg, 100);
      }
    } catch (e) {
      final String errorMsg = "Timer tick error: $e";
      debugPrint("FletServiceExtension._onTimerTick - $errorMsg");
      _triggerError(errorMsg, 500);
    }
  }

  // Event triggering methods
  
  /// Triggers a status change event with comprehensive state information.
  /// 
  /// Args:
  ///   status: The new status string (e.g., 'initialized', 'running', 'stopped')
  void _triggerStatusChange(String status) {
    try {
      final DateTime now = DateTime.now();
      final Map<String, dynamic> eventData = {
        "status": status,
        "timestamp": now.millisecondsSinceEpoch,
        "counter": _counter,
        "is_running": _isRunning,
        "is_paused": _isPaused,
        "interval": _interval,
        "max_count": _maxCount,
        "progress": _maxCount > 0 ? (_counter / _maxCount).clamp(0.0, 1.0) : 0.0,
        "uptime": _startTime != null ? now.difference(_startTime!).inSeconds : 0,
      };
      
      debugPrint("FletServiceExtension._triggerStatusChange - Status: $status, Data: $eventData");
      control.triggerEvent("status_change", eventData);
    } catch (e) {
      debugPrint("FletServiceExtension._triggerStatusChange - Error triggering status change: $e");
    }
  }
  
  /// Triggers a counter update event with progress information.
  /// 
  /// Args:
  ///   message: Descriptive message about the counter update
  void _triggerCounterUpdate(String message) {
    try {
      final DateTime now = DateTime.now();
      final double progress = _maxCount > 0 ? (_counter / _maxCount).clamp(0.0, 1.0) : 0.0;
      
      final Map<String, dynamic> eventData = {
        "count": _counter,
        "message": message,
        "timestamp": now.millisecondsSinceEpoch,
        "progress": progress,
        "max_count": _maxCount,
        "remaining": _maxCount - _counter,
        "percentage": (progress * 100).round(),
        "uptime": _startTime != null ? now.difference(_startTime!).inSeconds : 0,
      };
      
      debugPrint("FletServiceExtension._triggerCounterUpdate - Count: $_counter/$_maxCount (${(progress * 100).round()}%)");
      control.triggerEvent("counter_update", eventData);
    } catch (e) {
      debugPrint("FletServiceExtension._triggerCounterUpdate - Error triggering counter update: $e");
    }
  }
  
  /// Triggers an error event with detailed error information.
  /// 
  /// Args:
  ///   error: Error message or description
  ///   code: Error code for categorization
  void _triggerError(String error, int code) {
    try {
      final DateTime now = DateTime.now();
      final Map<String, dynamic> eventData = {
        "error": error,
        "code": code,
        "timestamp": now.millisecondsSinceEpoch,
        "counter": _counter,
        "service_status": _isRunning ? (_isPaused ? "paused" : "running") : "stopped",
        "uptime": _startTime != null ? now.difference(_startTime!).inSeconds : 0,
        "severity": _getSeverityFromCode(code),
      };
      
      debugPrint("FletServiceExtension._triggerError - Error [$code]: $error");
      control.triggerEvent("error", eventData);
    } catch (e) {
      debugPrint("FletServiceExtension._triggerError - Failed to trigger error event: $e");
    }
  }
  
  /// Determines error severity based on error code.
  /// 
  /// Args:
  ///   code: Error code
  /// 
  /// Returns:
  ///   Severity level as string
  String _getSeverityFromCode(int code) {
    if (code >= 500) return "critical";
    if (code >= 400) return "error";
    if (code >= 300) return "warning";
    if (code >= 200) return "info";
    return "debug";
  }

  @override
  void dispose() {
    try {
      debugPrint("FletServiceExtension(${control.id}).dispose() - Starting cleanup");
      
      // Stop service if running
      if (_isRunning) {
        debugPrint("FletServiceExtension.dispose - Stopping running service");
        _isRunning = false;
        _isPaused = false;
      }
      
      // Clean up timer resources
      if (_timer != null) {
        _timer!.cancel();
        _timer = null;
        debugPrint("FletServiceExtension.dispose - Timer cancelled");
      }
      
      // Remove method listener to prevent memory leaks
      control.removeInvokeMethodListener(_invokeMethod);
      debugPrint("FletServiceExtension.dispose - Method listener removed");
      
      // Trigger final status before disposal
      _triggerStatusChange("disposed");
      
      // Reset state variables
      _counter = 0;
      _startTime = null;
      
      debugPrint("FletServiceExtension(${control.id}).dispose() - Cleanup completed successfully");
      
      // Call parent dispose
      super.dispose();
    } catch (e) {
      debugPrint("FletServiceExtension.dispose - Error during disposal: $e");
      // Ensure parent dispose is called even if cleanup fails
      try {
        super.dispose();
      } catch (parentError) {
        debugPrint("FletServiceExtension.dispose - Error in parent dispose: $parentError");
      }
    }
  }
}
