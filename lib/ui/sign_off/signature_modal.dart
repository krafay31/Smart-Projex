import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:uuid/uuid.dart';
import '../../data/app_database.dart';
import '../../main.dart';
import '../../services/sign_off_service.dart';

class SignatureModal extends StatefulWidget {
  final SafetyCommunication communication;

  const SignatureModal({super.key, required this.communication});

  @override
  State<SignatureModal> createState() => _SignatureModalState();
}

class _SignatureModalState extends State<SignatureModal> {
  List<Map<String, dynamic>> _serverSignatures = [];
  List<AppUser> _allUsers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final service = SignOffService();
      final allSignatures = await service.fetchSignatures();
      final users = await db.select(db.appUsers).get();
      
      // Filter signatures for this communication
      final commSignatures = allSignatures
          .where((s) => s['communicationId'] == widget.communication.id)
          .toList();
      
      print('Loaded ${commSignatures.length} signatures for comm ${widget.communication.id}');
      
      setState(() {
        _serverSignatures = commSignatures;
        // Sort users alphabetically by name
        _allUsers = users..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading signatures: $e');
      setState(() => _isLoading = false);
    }
  }

  // Attendees who have signed (signature is not empty)
  List<Map<String, dynamic>> get _signedAttendees {
    return _serverSignatures.where((s) {
      final sig = s['signature']?.toString() ?? '';
      return sig.isNotEmpty && sig != 'null';
    }).toList();
  }

  // Attendees who haven't signed yet (signature is empty)
  List<Map<String, dynamic>> get _yetToSignAttendees {
    return _serverSignatures.where((s) {
      final sig = s['signature']?.toString() ?? '';
      return sig.isEmpty || sig == 'null';
    }).toList();
  }

  // Available users to add
  List<AppUser> get _availableUsers {
    final existingNames = _serverSignatures.map((s) => 
        (s['teamMember']?.toString() ?? '').toLowerCase()).toSet();
    return _allUsers.where((u) => 
        !existingNames.contains(u.name.toLowerCase()) &&
        u.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  Future<void> _addAttendee(AppUser user) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _AttendeeDetailsDialog(userName: user.name),
    );

    if (result != null) {
      try {
        final service = SignOffService();
        final sigId = const Uuid().v4();
        final now = DateTime.now().toIso8601String();
        
        // Clean payload matching API schema
        final payload = {
          'id': sigId,
          'uuid': sigId,
          'communicationId': widget.communication.id,
          'communicationuuid': widget.communication.id,
          'teamMember': user.name,
          'shift': result['shift'] ?? '',
          'signature': result['signature'] ?? '',
          'creationDateTime': now,
          'creationDate': now,
          'creationUser': UserSession.userEmail ?? UserSession.userName ?? '',
          'creationLocation': '', // Location latlong - can be added if device location is available
          'editDateTime': now,
          'editDate': now,
          'editUser': UserSession.userEmail ?? UserSession.userName ?? '',
          'editLocation': '', // Location latlong - can be added if device location is available
        };
        
        final success = await service.createSignature(payload);
        
        if (success) {
          _loadData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendee added'), backgroundColor: Colors.green),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add - check console'), backgroundColor: Colors.orange),
            );
          }
        }
      } catch (e) {
        print('Error adding attendee: $e');
      }
    }
  }

  Future<void> _editAttendee(Map<String, dynamic> attendee) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _AttendeeDetailsDialog(
        userName: attendee['teamMember']?.toString() ?? '',
        initialShift: attendee['shift']?.toString() ?? '',
        initialSignature: attendee['signature']?.toString() ?? '',
      ),
    );

    if (result != null) {
      try {
        final service = SignOffService();
        final sigId = attendee['id']?.toString() ?? attendee['uuid']?.toString() ?? '';
        await service.updateSignature(sigId, {
          ...attendee,
          'shift': result['shift'] ?? '',
          'signature': result['signature'] ?? '',
        });
        _loadData();
      } catch (e) {
        print('Error updating attendee: $e');
      }
    }
  }

  Future<void> _deleteAttendee(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Attendee'),
        content: const Text('Are you sure you want to remove this attendee?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await SignOffService().deleteSignature(id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 800,
        height: 650,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Attendees & Signatures', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text(widget.communication.title, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Two columns: Signed / Yet to Sign
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.textPrimary))
                  : Row(
                      children: [
                        // Signed Attendees Column
                        Expanded(
                          child: Container(
                            color: const Color(0xFFF0FDF4),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  color: const Color(0xFF16A34A),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      const Text('Signed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                        child: Text('${_signedAttendees.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: _signedAttendees.isEmpty
                                      ? const Center(child: Text('No signed attendees', style: TextStyle(color: Color(0xFF6B7280))))
                                      : ListView.builder(
                                          padding: const EdgeInsets.all(8),
                                          itemCount: _signedAttendees.length,
                                          itemBuilder: (context, index) => _buildAttendeeCard(_signedAttendees[index], true),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Divider
                        Container(width: 1, color: const Color(0xFFE5E7EB)),
                        // Yet to Sign Column
                        Expanded(
                          child: Container(
                            color: const Color(0xFFFEF3C7),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  color: const Color(0xFFD97706),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.pending, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      const Text('Yet to Sign', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                        child: Text('${_yetToSignAttendees.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: _yetToSignAttendees.isEmpty
                                      ? const Center(child: Text('No pending attendees', style: TextStyle(color: Color(0xFF6B7280))))
                                      : ListView.builder(
                                          padding: const EdgeInsets.all(8),
                                          itemCount: _yetToSignAttendees.length,
                                          itemBuilder: (context, index) => _buildAttendeeCard(_yetToSignAttendees[index], false),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            
            const Divider(height: 1),
            
            // Add New User Section - only for admins and creators
            Builder(
              builder: (context) {
                final currentUser = UserSession.userName ?? '';
                final isAdmin = UserSession.isAdmin;
                final deliveredBy = widget.communication.deliveredBy;
                final isCreator = deliveredBy.toLowerCase() == currentUser.toLowerCase();
                final canAddAttendees = isAdmin || isCreator;
                
                if (!canAddAttendees) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    color: const Color(0xFFF9FAFB),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Color(0xFF6B7280), size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'You can sign your own attendance. Only the creator can add new attendees.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFFF9FAFB),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_add, color: AppColors.textPrimary, size: 20),
                          const SizedBox(width: 8),
                          const Text('Add Attendee', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text('${_availableUsers.length} available', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search users...',
                                prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF6B7280)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                isDense: true,
                              ),
                              onChanged: (v) => setState(() => _searchQuery = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // User list with clickable items - matching create form UI
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _availableUsers.isEmpty
                            ? Center(child: Text(_searchQuery.isEmpty ? 'All users added' : 'No matches', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)))
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: _availableUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _availableUsers[index];
                                  return InkWell(
                                    onTap: () => _addAttendee(user),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: AppColors.textPrimary.withOpacity(0.1),
                                            child: Text(user.name[0].toUpperCase(), style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(child: Text(user.name, style: const TextStyle(fontSize: 13))),
                                          const Icon(Icons.add_circle_outline, color: AppColors.textPrimary, size: 20),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeeCard(Map<String, dynamic> attendee, bool isSigned) {
    final name = attendee['teamMember']?.toString() ?? 'Unknown';
    final shift = attendee['shift']?.toString() ?? '';
    final id = attendee['id']?.toString() ?? attendee['uuid']?.toString() ?? '';
    
    // Permission check
    final currentUser = UserSession.userName ?? '';
    final isAdmin = UserSession.isAdmin;
    final deliveredBy = widget.communication.deliveredBy;
    final isCreator = deliveredBy.toLowerCase() == currentUser.toLowerCase();
    final isOwnCard = name.toLowerCase() == currentUser.toLowerCase();
    final canEditDelete = isAdmin || isCreator;
    final canSign = canEditDelete || isOwnCard;

    // Use blue for pending (instead of orange) and green for signed
    final pendingColor = AppColors.textPrimary;
    final signedColor = Colors.green;
    final cardColor = isSigned ? signedColor : pendingColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cardColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: cardColor.withOpacity(0.1),
            child: Text(name[0].toUpperCase(), style: TextStyle(color: cardColor, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                if (shift.isNotEmpty)
                  Text('Shift: $shift', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          // Tap to edit/sign - only for own card or admin/creator
          if (canSign)
            IconButton(
              icon: Icon(isSigned ? Icons.edit : Icons.draw, size: 18, color: isSigned ? Colors.blue : Colors.orange),
              onPressed: () => _editAttendee(attendee),
              tooltip: isSigned ? 'Edit' : 'Add Signature',
            ),
          // Delete - only for admin/creator
          if (canEditDelete)
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: Colors.red),
              onPressed: () => _deleteAttendee(id),
              tooltip: 'Remove',
            ),
        ],
      ),
    );
  }
}

class _AttendeeDetailsDialog extends StatefulWidget {
  final String userName;
  final String initialShift;
  final String initialSignature;
  
  const _AttendeeDetailsDialog({
    required this.userName,
    this.initialShift = '',
    this.initialSignature = '',
  });
  
  @override
  State<_AttendeeDetailsDialog> createState() => _AttendeeDetailsDialogState();
}

class _AttendeeDetailsDialogState extends State<_AttendeeDetailsDialog> {
  late final TextEditingController _shiftController;
  late final TextEditingController _signatureController;

  @override
  void initState() {
    super.initState();
    _shiftController = TextEditingController(text: widget.initialShift);
    _signatureController = TextEditingController(text: widget.initialSignature);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.textPrimary.withOpacity(0.1),
            child: Text(widget.userName[0].toUpperCase(), style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userName, style: const TextStyle(fontSize: 16)),
                const Text('Enter shift and signature', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _shiftController,
            decoration: InputDecoration(
              labelText: 'Shift',
              hintText: 'e.g., Day, Night, Morning',
              prefixIcon: const Icon(Icons.schedule, color: Color(0xFF6B7280)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _signatureController,
            decoration: InputDecoration(
              labelText: 'Signature',
              hintText: 'Type name or initials to sign',
              prefixIcon: const Icon(Icons.draw, color: Color(0xFF6B7280)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'shift': _shiftController.text,
              'signature': _signatureController.text,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.textPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
