import 'package:animations/animations.dart';
import 'package:app010/colors.dart' as app_colors;
import 'package:app010/models/github_repo.dart';
import 'package:app010/services/repo_service_api.dart';
import 'package:app010/widgets/async_state_views.dart';
import 'package:app010/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onPageChange;

  const HomePage({super.key, this.onPageChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _service = GitHubServiceApi();
  late Future<List<MyGitHubRepo>> _reposFuture;

  static const _username = 'aymaneElyamani';

  @override
  void initState() {
    super.initState();
    _reposFuture = _service.getUserRepos(username: _username);
  }

  void _reload() {
    setState(() {
      _reposFuture = _service.getUserRepos(username: _username);
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(app_colors.primary);
    final secondary = Color(app_colors.secondary);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon mini CV'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: AppDrawer(onPageSelected: widget.onPageChange ?? (_) {}),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: Image.asset(
                      'assets/images/aymane.jpeg',
                    ).image,
                    backgroundColor: primary.withValues(alpha: 0.08),
                    child: Text(
                      'AE',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aymane El Yamani',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Université: Mundiapolis',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: secondary.withValues(alpha: 0.12),
                    ),
                    child: Text(
                      '@$_username',
                      style: TextStyle(
                        color: secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skills',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _SkillChip(label: 'React'),
                      _SkillChip(label: 'Next.js'),
                      _SkillChip(label: 'C'),
                      _SkillChip(label: 'Flutter'),
                      _SkillChip(label: 'Dart'),
                      _SkillChip(label: 'REST APIs'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mes repositories GitHub',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<MyGitHubRepo>>(
            future: _reposFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: LoadingView(message: 'Chargement des repos…'),
                );
              }
              if (snapshot.hasError) {
                return ErrorView(error: snapshot.error!, onRetry: _reload);
              }

              final repos = snapshot.data ?? const <MyGitHubRepo>[];
              if (repos.isEmpty) {
                return const EmptyView(message: 'Aucun repo trouvé.');
              }

              repos.sort((a, b) {
                final ad =
                    a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                final bd =
                    b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                return bd.compareTo(ad);
              });

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: repos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final repo = repos[index];
                  final subtitleParts = <String>[
                    if (repo.language.isNotEmpty) repo.language,
                    '⭐ ${repo.stargazersCount}',
                    '🍴 ${repo.forksCount}',
                  ];

                  return OpenContainer(
                    closedElevation: 0,
                    openElevation: 0,
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    openShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    closedColor: Colors.transparent,
                    openColor: Theme.of(context).scaffoldBackgroundColor,
                    transitionType: ContainerTransitionType.fadeThrough,
                    openBuilder: (context, _) => _RepoDetailsPage(repo: repo),
                    closedBuilder: (context, open) {
                      return Card(
                        child: ListTile(
                          onTap: open,
                          title: Text(
                            repo.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(subtitleParts.join('  •  ')),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final primary = Color(app_colors.primary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: primary.withValues(alpha: 0.06),
      ),
      child: Text(
        label,
        style: TextStyle(color: primary, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _RepoDetailsPage extends StatelessWidget {
  const _RepoDetailsPage({required this.repo});

  final MyGitHubRepo repo;

  @override
  Widget build(BuildContext context) {
    final primary = Color(app_colors.primary);

    return Scaffold(
      appBar: AppBar(title: Text(repo.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repo.fullName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(repo.description.isEmpty ? '—' : repo.description),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        label: repo.language.isEmpty
                            ? 'Unknown'
                            : repo.language,
                      ),
                      _MetaChip(label: '⭐ ${repo.stargazersCount}'),
                      _MetaChip(label: '🍴 ${repo.forksCount}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            repo.htmlUrl,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final primary = Color(app_colors.primary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: primary.withValues(alpha: 0.06),
      ),
      child: Text(
        label,
        style: TextStyle(color: primary, fontWeight: FontWeight.w600),
      ),
    );
  }
}
