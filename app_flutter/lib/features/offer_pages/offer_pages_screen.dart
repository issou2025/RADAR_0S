import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/lead_model.dart';
import '../../data/repositories/lead_repository.dart';

class OfferPagesScreen extends StatefulWidget {
  const OfferPagesScreen({super.key});

  @override
  State<OfferPagesScreen> createState() => _OfferPagesScreenState();
}

class _OfferPagesScreenState extends State<OfferPagesScreen> {
  final _leadRepo = LeadRepository();
  
  String _githubPagesBaseUrl = "";
  Map<String, int> _serviceLeadsCount = {};
  bool _isLoading = false;

  final List<OfferPageItem> _offers = [
    OfferPageItem(title: "Conversion PDF vers Revit", path: "/offers/pdf-to-revit.html", serviceType: "PDF_TO_REVIT"),
    OfferPageItem(title: "Modélisation DWG vers Revit", path: "/offers/dwg-to-revit.html", serviceType: "DWG_TO_REVIT"),
    OfferPageItem(title: "Plans de Maison & Conception", path: "/offers/house-plan-design.html", serviceType: "HOUSE_PLAN_DESIGN"),
    OfferPageItem(title: "Modélisation BIM Générale", path: "/offers/bim-modeling.html", serviceType: "BIM_MODELING"),
    OfferPageItem(title: "Plans de Structure Béton Armé", path: "/offers/structural-drawings.html", serviceType: "STRUCTURAL_DRAWINGS"),
    OfferPageItem(title: "Scan-to-BIM & Nuage de Points", path: "/offers/scan-to-bim.html", serviceType: "SCAN_TO_BIM"),
    OfferPageItem(title: "Dossier de Permis de Construire", path: "/offers/permit-drawings.html", serviceType: "PERMIT_DRAWINGS"),
    OfferPageItem(title: "Dessin Technique AutoCAD 2D", path: "/offers/autocad-drafting.html", serviceType: "AUTOCAD_DRAFTING"),
    OfferPageItem(title: "Métrés & Estimations", path: "/offers/quantity-takeoff.html", serviceType: "QUANTITY_TAKEOFF"),
    OfferPageItem(title: "Sites Web & Automatisation Python", path: "/offers/static-website.html", serviceType: "STATIC_WEBSITE"),
  ];

  @override
  void initState() {
    super.initState();
    _loadOfferData();
  }

  Future<void> _loadOfferData() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString(AppConstants.keyGithubPagesBaseUrl) ?? "";
    final leads = await _leadRepo.getAllLeads();
    
    // Group and count leads by service type
    final Map<String, int> counts = {};
    for (var l in leads) {
      counts[l.serviceType] = (counts[l.serviceType] ?? 0) + 1;
    }

    setState(() {
      _githubPagesBaseUrl = baseUrl;
      _serviceLeadsCount = counts;
      _isLoading = false;
    });
  }

  void _copyLink(String path) {
    final fullUrl = "$_githubPagesBaseUrl$path";
    Clipboard.setData(ClipboardData(text: fullUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Lien d'offre copié ! ($path)"),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Future<void> _openPage(String path) async {
    final fullUrl = "$_githubPagesBaseUrl$path";
    final uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Impossible d'ouvrir : $fullUrl"),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pages d'Offres Statiques"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _offers.length,
              itemBuilder: (context, index) {
                final offer = _offers[index];
                final count = _serviceLeadsCount[offer.serviceType] ?? 0;
                final published = _githubPagesBaseUrl.isNotEmpty;
                final fullUrl = "$_githubPagesBaseUrl${offer.path}";

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              offer.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: published ? AppTheme.success.withOpacity(0.1) : AppTheme.textMuted.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: published ? AppTheme.success.withOpacity(0.3) : AppTheme.textMuted.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                published ? "Publié" : "Non configuré",
                                style: TextStyle(
                                  fontSize: 10, 
                                  color: published ? AppTheme.success : AppTheme.textMuted,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Chemin: ${offer.path}",
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                        ),
                        if (published) ...[
                          const SizedBox(height: 4),
                          Text(
                            "URL: $fullUrl",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$count opportunité${count > 1 ? 's' : ''} associée${count > 1 ? 's' : ''}",
                              style: TextStyle(
                                fontSize: 12, 
                                color: count > 0 ? AppTheme.primaryColor : AppTheme.textMuted,
                                fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 20),
                                  tooltip: "Copier le lien",
                                  onPressed: published ? () => _copyLink(offer.path) : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.open_in_new, size: 20),
                                  tooltip: "Ouvrir la page",
                                  onPressed: published ? () => _openPage(offer.path) : null,
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class OfferPageItem {
  final String title;
  final String path;
  final String serviceType;

  OfferPageItem({
    required this.title,
    required this.path,
    required this.serviceType,
  });
}
