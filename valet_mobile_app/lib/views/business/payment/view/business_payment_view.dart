import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:valet_mobile_app/views/business/payment/controller/business_payment_controller.dart';

class BusinessPaymentView extends GetView<BusinessPaymentController> {
  const BusinessPaymentView({Key? key}) : super(key: key);

  Widget _buildTicketSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[700],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: TextField(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter Ticket ID',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) => controller.ticketId.value = value,
                    onSubmitted: (value) => controller.checkTicket(value),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: controller.isCheckingTicket.value
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : IconButton(
                            key: const ValueKey('search'),
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () => controller.checkTicket(controller.ticketId.value),
                          ),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      child: child,
                    ),
                  );
                },
                child: controller.parkingDuration.value.isNotEmpty
                    ? Column(
                        key: const ValueKey('duration'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Parking Duration:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.parkingDuration.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              )),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            'Credit Card',
            Icons.credit_card,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            'Cash',
            Icons.money,
            Colors.green,
          ),
          const SizedBox(height: 20),
          const Text(
            'Amount',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter amount',
                    prefixText: '\$',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => controller.decreaseAmount(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => controller.increaseAmount(),
                        ),
                      ],
                    ),
                  ),
                  controller: TextEditingController(text: controller.amount.value.toStringAsFixed(2)),
                  onChanged: (value) => controller.amount.value = double.tryParse(value) ?? controller.amount.value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildTipPercentageButton('10%', 0.10),
                  const SizedBox(width: 8),
                  _buildTipPercentageButton('15%', 0.15),
                  const SizedBox(width: 8),
                  _buildTipPercentageButton('20%', 0.20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter tip amount',
                    prefixText: '\$',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => controller.decreaseTip(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => controller.increaseTip(),
                        ),
                      ],
                    ),
                  ),
                  controller: TextEditingController(text: controller.tip.value.toStringAsFixed(2)),
                  onChanged: (value) => controller.tip.value = double.tryParse(value) ?? controller.tip.value,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, Color color) {
    return Obx(() => InkWell(
          onTap: () => controller.selectedPaymentMethod.value = title,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: controller.selectedPaymentMethod.value == title ? color.withOpacity(0.1) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: controller.selectedPaymentMethod.value == title ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: controller.selectedPaymentMethod.value == title ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: controller.selectedPaymentMethod.value == title ? 1 : 0,
                  child: Icon(
                    Icons.check_circle,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildTipPercentageButton(String text, double percentage) {
    return Obx(() => ElevatedButton(
          onPressed: () => controller.setTipPercentage(percentage),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.selectedTipPercentage.value == percentage ? Colors.blue[700] : Colors.grey[200],
            foregroundColor: controller.selectedTipPercentage.value == percentage ? Colors.white : Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(text),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTicketSection(),
            Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        child: child,
                      ),
                    );
                  },
                  child: controller.parkingDuration.value.isNotEmpty
                      ? Column(
                          key: const ValueKey('payment-section'),
                          children: [
                            _buildPaymentSection(),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              child: Hero(
                                tag: 'payment_button',
                                child: ElevatedButton(
                                  onPressed: controller.isLoading.value ? null : controller.processPayment,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[700],
                                    minimumSize: const Size(double.infinity, 56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Complete Payment',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                )),
          ],
        ),
      ),
    );
  }
}
