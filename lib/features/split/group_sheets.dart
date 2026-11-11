import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/note_utils.dart';
import '../../data/database/app_database.dart';
import '../../shared/widgets/pill_chip.dart';
import '../../shared/widgets/sheets.dart';
import 'split_providers.dart';
import 'widgets/person_avatar.dart';

Future<T?> _showSheet<T>(BuildContext context, Widget sheet) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: AppMotion.page,
      reverseDuration: AppMotion.normal,
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: sheet,
    ),
  );
}

/// New group: a name and its people. Jack is always in, first; names from
/// earlier groups wait below as chips. Returns the new group's id.
Future<String?> showNewGroupSheet(BuildContext context) =>
    _showSheet<String>(context, const _NewGroupSheet());

/// A group's people: tap one to rename or remove them, add more by name or
/// from earlier groups.
Future<void> showPeopleSheet(BuildContext context, String groupId) =>
    _showSheet<void>(context, _PeopleSheet(groupId));

/// Same name, ignoring case and spaces.
bool _sameName(String a, String b) =>
    a.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase() ==
    b.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

class _NewGroupSheet extends ConsumerStatefulWidget {
  const _NewGroupSheet();

  @override
  ConsumerState<_NewGroupSheet> createState() => _NewGroupSheetState();
}

class _NewGroupSheetState extends ConsumerState<_NewGroupSheet> {
  final TextEditingController _name = TextEditingController();
  final List<String> _others = [];
  String? _meName;
  bool _creating = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _add(String name) {
    final cleaned = cleanNote(name);
    if (cleaned == null || _others.any((o) => _sameName(o, cleaned))) return;
    setState(() => _others.add(cleaned));
  }

  Future<void> _renameMe(String current) async {
    final name = await showTextInputDialog(
      context,
      title: AppStrings.yourName,
      message: AppStrings.yourNameMessage,
      placeholder: current,
    );
    if (name != null && mounted) setState(() => _meName = name);
  }

  Future<void> _create(String meName) async {
    final name = cleanNote(_name.text);
    if (name == null || _creating) return;
    setState(() => _creating = true);
    final id = await ref
        .read(splitActionsProvider)
        .createGroup(name: name, meName: meName, others: _others);
    if (mounted) Navigator.of(context).pop(id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final meName =
        _meName ??
        ref.watch(meNameProvider).valueOrNull ??
        AppStrings.meDefaultName;
    final earlier = [
      for (final name in ref.watch(earlierNamesProvider).valueOrNull ?? [])
        if (!_others.any((o) => _sameName(o, name))) name,
    ];
    return _SheetBody(
      title: AppStrings.newGroup,
      children: [
        TextField(
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
          style: AppTextStyles.body.copyWith(color: colors.label),
          decoration: const InputDecoration(
            hintText: AppStrings.groupNamePlaceholder,
          ),
        ),
        const _Label(AppStrings.people),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _PersonChip(
              name: meName,
              index: 0,
              label: AppStrings.youChip(meName),
              onTap: () => _renameMe(meName),
            ),
            for (final (index, name) in _others.indexed)
              _PersonChip(
                name: name,
                index: index + 1,
                trailing: Icons.close_rounded,
                onTap: () => setState(() => _others.removeAt(index)),
              ),
          ],
        ),
        _AddNameField(onAdd: _add),
        if (earlier.isNotEmpty) ...[
          const _Label(AppStrings.fromEarlierGroups),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final name in earlier)
                _PersonChip(
                  name: name,
                  index: _others.length + 1,
                  trailing: Icons.add_rounded,
                  onTap: () => _add(name),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          onPressed: cleanNote(_name.text) == null || _creating
              ? null
              : () => _create(meName),
          child: const Text(AppStrings.create),
        ),
      ],
    );
  }
}

class _PeopleSheet extends ConsumerWidget {
  const _PeopleSheet(this.groupId);

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(splitPeopleProvider(groupId)).valueOrNull ?? [];
    final actions = ref.read(splitActionsProvider);
    final earlier = [
      for (final name in ref.watch(earlierNamesProvider).valueOrNull ?? [])
        if (!people.any((p) => _sameName(p.name, name))) name,
    ];
    void add(String name) {
      final cleaned = cleanNote(name);
      if (cleaned == null || people.any((p) => _sameName(p.name, cleaned))) {
        return;
      }
      actions.addPerson(groupId, cleaned);
    }

    return _SheetBody(
      title: AppStrings.people,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final (index, person) in people.indexed)
              _PersonChip(
                name: person.name,
                index: index,
                label: person.isMe ? AppStrings.youChip(person.name) : null,
                onTap: () => _personMenu(context, actions, person),
              ),
          ],
        ),
        _AddNameField(onAdd: add),
        if (earlier.isNotEmpty) ...[
          const _Label(AppStrings.fromEarlierGroups),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final name in earlier)
                _PersonChip(
                  name: name,
                  index: people.length,
                  trailing: Icons.add_rounded,
                  onTap: () => add(name),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Future<void> _personMenu(
    BuildContext context,
    SplitActions actions,
    SplitPerson person,
  ) async {
    final remove = await showOptionsSheet<bool>(
      context,
      title: person.name,
      options: [
        const SheetOption(AppStrings.renamePerson, false),
        if (!person.isMe)
          const SheetOption(AppStrings.removePerson, true, destructive: true),
      ],
    );
    if (remove == null || !context.mounted) return;
    if (!remove) {
      final name = await showTextInputDialog(
        context,
        title: person.isMe ? AppStrings.yourName : AppStrings.renamePerson,
        message: person.isMe ? AppStrings.yourNameMessage : null,
        placeholder: person.name,
      );
      if (name != null) await actions.renamePerson(person.id, name);
      return;
    }
    if (!await actions.removePerson(person.id) && context.mounted) {
      await showAlert(
        context,
        title: AppStrings.cannotRemoveTitle(person.name),
        message: AppStrings.cannotRemoveMessage,
      );
    }
  }
}

/// A sheet's title and its content, padded and scrolling when tall.
class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.title2.copyWith(color: colors.label),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.caption1.copyWith(
          color: context.colors.sectionLabel,
        ),
      ),
    );
  }
}

/// A person as a chip: their initial, their name (or [label]) and, when
/// given, a small [trailing] mark for what a tap does.
class _PersonChip extends StatelessWidget {
  const _PersonChip({
    required this.name,
    required this.index,
    required this.onTap,
    this.label,
    this.trailing,
  });

  final String name;
  final int index;
  final String? label;
  final IconData? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    return PillChip(
      label: label ?? name,
      selected: false,
      labelColor: context.colors.label,
      onTap: onTap,
      leading: PersonAvatar(
        name: name,
        index: index,
        size: AppSizes.personChipAvatar,
      ),
      trailing: trailing == null
          ? null
          : Icon(
              trailing,
              size: AppSizes.labelIcon,
              color: context.colors.labelSecondary,
            ),
    );
  }
}

/// `Add a name`, with + to add what was typed (Enter adds it too).
class _AddNameField extends StatefulWidget {
  const _AddNameField({required this.onAdd});

  final ValueChanged<String> onAdd;

  @override
  State<_AddNameField> createState() => _AddNameFieldState();
}

class _AddNameFieldState extends State<_AddNameField> {
  final TextEditingController _text = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _add() {
    widget.onAdd(_text.text);
    _text.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: TextField(
        controller: _text,
        focusNode: _focus,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _add(),
        style: AppTextStyles.body.copyWith(color: colors.label),
        decoration: InputDecoration(
          hintText: AppStrings.addName,
          suffixIcon: IconButton(
            tooltip: AppStrings.addPerson,
            icon: Icon(Icons.add_rounded, color: colors.accent),
            onPressed: _add,
          ),
        ),
      ),
    );
  }
}
