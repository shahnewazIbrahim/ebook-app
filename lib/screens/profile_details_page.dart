import 'package:ebook_project/components/app_layout.dart';
import 'package:flutter/material.dart';

class ProfileDetailsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const ProfileDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final name = _stringOrNA(user['name']);
    final email = _stringOrNA(user['email']);
    final photo = (user['photo'] ?? '') as String?;
    final statusVal = user['status'];
    final isActive = statusVal == 1 || statusVal == '1' || statusVal == true;

    return AppLayout(
      title: 'Profile',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        child: Column(
          children: [
            // --- Header card (সিম্পল প্রোফাইল সামারি) ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor.withOpacity(.2)),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: (photo != null && photo.trim().isNotEmpty)
                        ? NetworkImage(photo)
                        : null,
                    child: (photo == null || photo.trim().isEmpty)
                        ? const Icon(Icons.person, size: 36, color: Colors.black54)
                        : null,
                    onBackgroundImageError: (_, __) {},
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            )),
                        const SizedBox(height: 4),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        const SizedBox(height: 8),
                        _statusChip(isActive),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Profile Info (ফিল্ডভিত্তিক) ---
            _SectionCard(
              title: 'Profile Info',
              children: [
                _kvTile('Name', name),
                _kvTile('Email', email.isEmpty ? 'N/A' : email),
                _kvTile('Phone', _stringOrNA(user['phone_number'])),
                _kvTile('Gender', _stringOrNA(user['gender'])),
                _kvTile('BMDC No', _stringOrNA(user['bmdc_no'])),
                _kvTile('User Type',
                    (user['type'] == 1) ? 'User' : (user['type'] == 2 ? 'Admin' : _stringOrNA(user['type']))),
                _kvTile('Birthdate', _stringOrNA(user['date_of_birth'])),
                _kvTile('Facebook', _stringOrNA(user['facebook_id_link'])),
                _kvTile('Created At', _stringOrNA(user['created_at'])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- helpers ----------

  static String _stringOrNA(dynamic v) {
    if (v == null) return 'N/A';
    final s = v.toString().trim();
    return s.isEmpty ? 'N/A' : s;
  }

  Widget _statusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// -------------------- Reusable section card & kv tile --------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = BorderSide(color: theme.dividerColor.withOpacity(.2));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.fromBorderSide(border),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ..._withDividers(children),
        ],
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> tiles) {
    final out = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      out.add(tiles[i]);
      if (i != tiles.length - 1) {
        out.add(const Divider(height: 1));
      }
    }
    return out;
  }
}

Widget _kvTile(String k, String v) {
  return ListTile(
    dense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    title: Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
    trailing: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          v,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    ),
  );
}
