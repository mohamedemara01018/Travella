import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/note.dart';
import '../models/trip.dart';

class TripNotesScreen extends StatefulWidget {
  final String tripId;
  const TripNotesScreen({super.key, required this.tripId});

  @override
  State<TripNotesScreen> createState() => _TripNotesScreenState();
}

class _TripNotesScreenState extends State<TripNotesScreen> {
  int _selectedDay = 1;
  // Controllers
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  String _selectedCategory = 'Transport';
  bool _isLoading = false;

  // Colors
  final Color _textPrimary = const Color(0xFF0F172A);
  final Color _textSecondary = const Color(0xFF334155);
  final Color _textMuted = const Color(0xFF64748B);

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Trip?>(
      stream: Provider.of<DatabaseService>(context).getTrip(widget.tripId),
      builder: (context, tripSnapshot) {
        if (!tripSnapshot.hasData || tripSnapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final trip = tripSnapshot.data!;
        final days = trip.endDate.difference(trip.startDate).inDays + 1;
        final dateFormat = DateFormat('d EEE');

        return StreamBuilder<List<Note>>(
          stream: Provider.of<DatabaseService>(context)
              .getNotesByDay(widget.tripId, _selectedDay),
          builder: (context, notesSnapshot) {
            final notes = notesSnapshot.data ?? [];

            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // --- SECTION 1: DAY SELECTOR ---
                    SliverToBoxAdapter(
                      child: Container(
                        height: 70,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: days,
                          itemBuilder: (context, index) {
                            final dayNumber = index + 1;
                            final isSelected = _selectedDay == dayNumber;
                            final dayDate = trip.startDate.add(Duration(days: index));

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => setState(() => _selectedDay = dayNumber),
                                borderRadius: BorderRadius.circular(14),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: isSelected ? AppTheme.blueGradient : null,
                                    color: isSelected ? null : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: isSelected ? null : Border.all(color: Colors.grey[300]!),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.primaryBlue.withOpacity(0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Day $dayNumber',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? Colors.white : _textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateFormat.format(dayDate).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white70 : _textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // --- SECTION 2: ADD NOTE BUTTON (REPLACED FORM) ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: InkWell(
                          onTap: () => _showAddNoteSheet(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, color: AppTheme.primaryBlue),
                                SizedBox(width: 8),
                                Text(
                                  "Add Note for Day $_selectedDay",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // --- SECTION 3: NOTES LIST HEADER ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Text(
                          'Your Notes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // --- SECTION 4: NOTES LIST ---
                    if (notes.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80, height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppTheme.blueGradientLight.scale(0.1),
                                  ),
                                  child: Icon(Icons.note_alt_outlined, size: 40, color: AppTheme.primaryBlue.withOpacity(0.5)),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No notes yet',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textPrimary),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the button above to add one',
                                  style: TextStyle(color: _textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: _buildNoteItemFromModel(context, notes[index]),
                            );
                          },
                          childCount: notes.length,
                        ),
                      ),
                      
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- SHOW ADD NOTE BOTTOM SHEET ---
  void _showAddNoteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Note',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textPrimary),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Title (e.g., Reservation)',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              style: TextStyle(color: _textPrimary),
              decoration: InputDecoration(
                hintText: 'Write down details...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              dropdownColor: Colors.white,
              style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: 'Category',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: ['Transport', 'Logistics', 'Food', 'Activities', 'Other']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => _selectedCategory = v!,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveNote();
                  if (mounted) Navigator.pop(context); // Close sheet on success
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Note', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET: NOTE CARD ---
  Widget _buildNoteItemFromModel(BuildContext context, Note note) {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final timeFormat = DateFormat('h:mm a');

    return InkWell(
      onTap: () {
        _showNoteDetails(context, note);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700, color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                note.category,
                                style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              timeFormat.format(note.createdAt),
                              style: TextStyle(fontSize: 11, color: _textMuted, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // --- ACTION MENU ---
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz, color: _textMuted),
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final success = await databaseService.deleteNote(note.id);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Note deleted'), backgroundColor: Colors.red),
                          );
                        }
                      } else if (value == 'edit') {
                        _showEditNoteDialog(context, note);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, color: AppTheme.primaryBlue, size: 20),
                            SizedBox(width: 12),
                            Text('Edit', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                            SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, color: _textSecondary, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DETAILS DIALOG ---
  void _showNoteDetails(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textPrimary),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note.category,
                  style: const TextStyle(
                    color: AppTheme.primaryBlue, fontWeight: FontWeight.w700, fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    note.content,
                    style: TextStyle(fontSize: 16, height: 1.6, color: _textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- EDIT DIALOG ---
  void _showEditNoteDialog(BuildContext context, Note note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);
    String selectedCategory = note.category;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Note', style: TextStyle(fontWeight: FontWeight.w800, color: _textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: _textMuted),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                maxLines: 4,
                style: TextStyle(color: _textPrimary),
                decoration: InputDecoration(
                  labelText: 'Details',
                  labelStyle: TextStyle(color: _textMuted),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                dropdownColor: Colors.white,
                style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: _textMuted),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: ['Transport', 'Logistics', 'Food', 'Activities', 'Other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => selectedCategory = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: _textMuted, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || contentController.text.isEmpty) return;

              final updatedNote = note.copyWith(
                title: titleController.text.trim(),
                content: contentController.text.trim(),
                category: selectedCategory,
              );

              final success = await Provider.of<DatabaseService>(context, listen: false)
                  .updateNote(updatedNote);

              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note updated!'), backgroundColor: AppTheme.primaryBlue),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // --- SAVE LOGIC ---
  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty || _detailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please fill all fields'), backgroundColor: Colors.red),
      );
      return;
    }

    // Set loading state if you want to show spinner in the sheet
    // setState(() => _isLoading = true);

    final note = Note(
      id: '',
      tripId: widget.tripId,
      dayNumber: _selectedDay,
      title: _titleController.text.trim(),
      content: _detailsController.text.trim(),
      category: _selectedCategory,
      createdAt: DateTime.now(),
    );

    final databaseService = Provider.of<DatabaseService>(context, listen: false);

    try {
      final noteId = await databaseService.createNote(note);
      
      if (noteId != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note saved successfully!'),
            backgroundColor: AppTheme.primaryBlue,
          ),
        );
        _titleController.clear();
        _detailsController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }
}