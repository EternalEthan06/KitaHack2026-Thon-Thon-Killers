import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/firestore_service.dart';
import '../../core/models/ngo_model.dart';
import '../../core/theme/app_theme.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🛍️ NGO Marketplace')),
      body: StreamBuilder<List<MarketplaceProduct>>(
        stream: DatabaseService.watchProducts(),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary));
          if (snap.data!.isEmpty) {
            return const Center(
                child: Text('No products yet. Check back soon!',
                    style: TextStyle(color: AppTheme.onSurfaceMuted)));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72),
            itemCount: snap.data!.length,
            itemBuilder: (_, i) => _ProductCard(product: snap.data![i]),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final MarketplaceProduct product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: product.imageURL.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.imageURL,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppTheme.surfaceVariant),
                    errorWidget: (_, __, ___) => Container(
                        color: AppTheme.surfaceVariant,
                        child: const Icon(Icons.shopping_bag_rounded,
                            color: AppTheme.onSurfaceMuted)))
                : Container(
                    color: AppTheme.surfaceVariant,
                    child: const Center(
                        child: Text('🛍️', style: TextStyle(fontSize: 40)))),
          ),
          // Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(product.ngoName,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.onSurfaceMuted)),
                  const Spacer(),
                  Row(children: [
                    Text('RM ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showOrderSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add_shopping_cart_rounded,
                            color: Colors.black, size: 16),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(product.description,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text('RM ${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
                spacing: 6,
                children: product.sdgGoals.map((g) {
                  final idx = g - 1;
                  final color = idx >= 0 && idx < AppTheme.sdgColors.length
                      ? AppTheme.sdgColors[idx]
                      : AppTheme.primary;
                  return Chip(
                      label: Text('SDG $g',
                          style: TextStyle(color: color, fontSize: 11)),
                      backgroundColor: color.withOpacity(0.1),
                      side: BorderSide.none,
                      padding: EdgeInsets.zero);
                }).toList()),
            const SizedBox(height: 20),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('🛍️ Order submitted! NGO will contact you.'),
                        backgroundColor: AppTheme.primary));
                  },
                  child: const Text('Place Order'),
                )),
          ],
        ),
      )),
    );
  }
}
