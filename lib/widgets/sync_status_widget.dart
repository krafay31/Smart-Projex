import 'package:flutter/material.dart';
import 'dart:async';
import '../services/sync_service.dart';
import '../main.dart';

class SyncStatusWidget extends StatefulWidget {
  final VoidCallback? onSyncComplete;
  
  const SyncStatusWidget({super.key, this.onSyncComplete});

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  StreamSubscription<SyncStatus>? _subscription;
  SyncStatus _currentStatus = SyncStatus.idle;
  bool _isSyncing = false;
  
  Future<void> _syncNow() async {
    if (_isSyncing) return;
    
    setState(() => _isSyncing = true);
    
    try {
      print('🔄 Refreshing data from server...');
      
      // ✅ Sync lightweight reference data
      await syncService.syncSitesAndLocations();
      
      // ✅ Call parent to reload current page from API
      if (widget.onSyncComplete != null) {
        widget.onSyncComplete!.call();
      }
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data refreshed successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ Refresh error: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Refresh failed: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }



  @override
  void initState() {
    super.initState();
    _subscription = syncService.syncStatus.listen((status) {
      if (mounted) {
        setState(() {
          _currentStatus = status;
        });
        
        // Call the callback when sync completes
        if (status == SyncStatus.synced) {
          widget.onSyncComplete?.call();
        }
      }
    });
    
    // Set initial status
    if (syncService.isCurrentlyOnline) {
      _currentStatus = SyncStatus.synced;
    } else {
      _currentStatus = SyncStatus.offline;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (_currentStatus) {
      case SyncStatus.syncing:
        statusColor = Colors.orange;
        statusIcon = Icons.sync;
        statusText = 'Syncing...';
        break;
      case SyncStatus.synced:
        statusColor = Colors.green;
        statusIcon = Icons.cloud_done;
        statusText = 'Synced';
        break;
      case SyncStatus.offline:
        statusColor = Colors.red;
        statusIcon = Icons.cloud_off;
        statusText = 'Offline';
        break;
      case SyncStatus.error:
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        statusText = 'Error';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.cloud_queue;
        statusText = 'Idle';
    }

    return PopupMenuButton<String>(
      icon: Stack(
        children: [
          Icon(statusIcon, color: statusColor),
          if (_isSyncing)
            Positioned.fill(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
        ],
      ),
      tooltip: statusText,
      offset: const Offset(0, 45),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(statusText),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'sync',
          enabled: !_isSyncing,
          child: Row(
            children: [
              Icon(
                Icons.sync,
                size: 20,
                color: _isSyncing ? Colors.grey : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 12),
              Text(
                'Sync Now',
                style: TextStyle(
                  color: _isSyncing ? Colors.grey : null,
                ),
              ),
            ],
          ),
        ),
        if (syncService.lastSyncTime != null)
          PopupMenuItem(
            enabled: false,
            child: Text(
              'Last sync: ${_formatLastSync(syncService.lastSyncTime!)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ),
      ],
      onSelected: (value) {
        if (value == 'sync') {
          _syncNow();
        }
      },
    );
  }

  String _formatLastSync(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildStatusIcon({bool showAnimation = true}) {
    switch (_currentStatus) {
      case SyncStatus.syncing:
        return showAnimation
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                ),
              )
            : const Icon(Icons.sync, color: Color(0xFFFF6B35), size: 20);
      
      case SyncStatus.synced:
        return const Icon(Icons.cloud_done, color: Color(0xFF16A34A), size: 20);
      
      case SyncStatus.offline:
        return const Icon(Icons.cloud_off, color: Color(0xFF6B7280), size: 20);
      
      case SyncStatus.error:
        return const Icon(Icons.cloud_off, color: Color(0xFFDC2626), size: 20);
      
      case SyncStatus.idle:
      return const Icon(Icons.cloud_queue, color: Color(0xFF6B7280), size: 20);
    }
  }

  String _getStatusText() {
    switch (_currentStatus) {
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.error:
        return 'Sync Error';
      case SyncStatus.idle:
      return 'Ready';
    }
  }
}