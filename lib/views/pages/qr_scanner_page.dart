import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../../controllers/qr_controller.dart';
import '../../controllers/cart_controller.dart';
import '../components/quantity_selector.dart';
import 'cart_page.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRController?
  _qrController; // Store reference to avoid context access in dispose

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to controller to use in dispose
    _qrController = context.read<QRController>();
  }

  @override
  void reassemble() {
    super.reassemble();
    // Use the stored controller reference instead of context
    _qrController?.reassembleCamera();
  }

  void _onQRViewCreated(QRViewController controller) {
    context.read<QRController>().setQRViewController(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<QRController>(
        builder: (context, qrController, child) {
          // Show item found dialog when item is scanned
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (qrController.scannedItem != null) {
              _showItemFoundDialog(
                context,
                qrController.scannedItem!,
                qrController,
              );
            } else if (qrController.errorMessage != null &&
                !qrController.isProcessing) {
              // Only show error dialog if not currently processing
              _showItemNotFoundDialog(context, qrController.errorMessage!);
            }
          });

          return Column(
            children: [
              // QR Scanner View
              Expanded(
                flex: 4,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.green[600]!,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 250,
                  ),
                ),
              ),

              // Scanner Status
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (qrController.isProcessing) ...[
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Processing QR code...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        Icon(
                          Icons.qr_code_scanner,
                          size: 48,
                          color: Colors.green[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Point your camera at a QR code to scan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Make sure the QR code is well-lit and clearly visible',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showItemFoundDialog(context, item, QRController qrController) {
    int quantity = 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600]),
                  const SizedBox(width: 8),
                  const Text('Item Found!'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: 120,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Product Details
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '\$${item.price.toStringAsFixed(2)} per ${item.unit}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quantity Selector
                    QuantitySelector(
                      quantity: quantity,
                      onQuantityChanged: (newQuantity) {
                        setState(() {
                          quantity = newQuantity;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Total Price
                    Text(
                      'Total: \$${(item.price * quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    qrController.resumeCamera();
                    qrController.clearScannedItem();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<CartController>().addItem(item, quantity);
                    Navigator.pop(context);

                    // Show success dialog with options
                    _showItemAddedDialog(context, item, quantity, qrController);
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showItemAddedDialog(
    BuildContext context,
    item,
    int quantity,
    QRController qrController,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600]),
              const SizedBox(width: 8),
              const Text('Added to Cart!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_cart, size: 64, color: Colors.green[600]),
              const SizedBox(height: 16),
              Text(
                '${item.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Quantity: $quantity',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Total: \$${(item.price * quantity).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);

                // Navigate to cart page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('View Cart'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue[600]),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name} added to cart'),
                    backgroundColor: Colors.green[600],
                    duration: const Duration(seconds: 2),
                  ),
                );

                // Resume scanning
                qrController.resumeCamera();
                qrController.clearScannedItem();
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Continue Scanning'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showItemNotFoundDialog(BuildContext context, String errorMessage) {
    final qrController = context.read<QRController>();

    // Pause camera immediately to prevent further scanning
    qrController.pauseCamera();

    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.orange[600]),
              const SizedBox(width: 8),
              const Text('Item Not Found'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_2, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                errorMessage.contains('not found')
                    ? 'The scanned QR code doesn\'t match any items in our catalog.'
                    : errorMessage,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                qrController.clearError();
                qrController.resumeCamera();
              },
              child: const Text('Try Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                qrController.clearError();
                Navigator.pop(context); // Go back to catalog
              },
              child: const Text('Back to Catalog'),
            ),
          ],
        );
      },
    ).then((_) {
      // Ensure cleanup happens even if dialog is dismissed by tapping outside
      qrController.clearError();
      if (Navigator.canPop(context)) {
        qrController.resumeCamera();
      }
    });
  }
}