class SettingsModel {
  final String githubUsername;
  final String repositoryName;
  final String branch;
  final String githubPagesBaseUrl;
  final String leadsPath;
  final String userActionsPath;

  SettingsModel({
    required this.githubUsername,
    required this.repositoryName,
    required this.branch,
    required this.githubPagesBaseUrl,
    required this.leadsPath,
    required this.userActionsPath,
  });

  factory SettingsModel.empty() {
    return SettingsModel(
      githubUsername: "",
      repositoryName: "client-radar-os-private",
      branch: "main",
      githubPagesBaseUrl: "",
      leadsPath: "data/leads.json",
      userActionsPath: "data/user_actions.json",
    );
  }

  SettingsModel copyWith({
    String? githubUsername,
    String? repositoryName,
    String? branch,
    String? githubPagesBaseUrl,
    String? leadsPath,
    String? userActionsPath,
  }) {
    return SettingsModel(
      githubUsername: githubUsername ?? this.githubUsername,
      repositoryName: repositoryName ?? this.repositoryName,
      branch: branch ?? this.branch,
      githubPagesBaseUrl: githubPagesBaseUrl ?? this.githubPagesBaseUrl,
      leadsPath: leadsPath ?? this.leadsPath,
      userActionsPath: userActionsPath ?? this.userActionsPath,
    );
  }
}
