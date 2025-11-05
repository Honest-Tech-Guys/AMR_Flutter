import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/home/home_provider/home_provider.dart';
import 'package:rms_tenant_app/shared/models/tenancy_model.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AgreementScreen extends ConsumerWidget {
  const AgreementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenancyAsyncValue = ref.watch(homeTenancyProvider);
    const Color primaryColor = Color(0xFF076633);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Agreement',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.white,
          elevation: 0.5,
          bottom: const TabBar(
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryColor,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            tabs: [
              Tab(text: 'Agreement'),
              Tab(text: 'Tenancy'),
              Tab(text: 'Documents'),
            ],
          ),
        ),
        backgroundColor: Colors.grey[50],
        body: tenancyAsyncValue.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: primaryColor),
          ),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $err', textAlign: TextAlign.center),
              ],
            ),
          ),
          data: (tenancy) {
            return TabBarView(
              children: [
                _buildAgreementDetailsTab(context, tenancy),
                _buildTenancyDetailsTab(context, tenancy),
                _buildDocumentsTab(context, tenancy),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAgreementDetailsTab(BuildContext context, Tenancy tenancy) {
    const Color primaryColor = Color(0xFF076633);
    
    final endDate = DateTime.parse(tenancy.agreement.endDate);
    final today = DateTime.now();
    final daysRemaining = endDate.difference(today).inDays;
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildStatusCard(tenancy, daysRemaining, primaryColor),
        const SizedBox(height: 16),
        
        _buildSectionTitle('Agreement Information'),
        const SizedBox(height: 8),
        _buildDetailCard([
          _buildEnhancedDetailRow(
            'Agreement Code',
            tenancy.code,
            Icons.confirmation_number_outlined,
          ),
          const Divider(height: 24),
          _buildEnhancedDetailRow(
            'Agreement Date',
            tenancy.agreement.agreementDate,
            Icons.calendar_today_outlined,
          ),
          const Divider(height: 24),
          _buildEnhancedDetailRow(
            'Duration',
            '${tenancy.agreement.startDate} to ${tenancy.agreement.endDate}',
            Icons.date_range_outlined,
          ),
        ]),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('Landlord Information'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(20),
              title: _buildPartyRow(
                'Landlord',
                tenancy.tenantable.unit.property.owner.name,
                Icons.person_outline,
                primaryColor,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                if (tenancy.tenantable.unit.property.owner.ownerProfile.nricNumber != null) ...[
                  _buildEnhancedDetailRow(
                    'NRIC',
                    tenancy.tenantable.unit.property.owner.ownerProfile.nricNumber!,
                    Icons.badge_outlined,
                  ),
                ],
                if (tenancy.tenantable.unit.property.owner.ownerProfile.altPhoneNumber != null) ...[
                  const Divider(height: 24),
                  _buildEnhancedDetailRow(
                    'Phone',
                    tenancy.tenantable.unit.property.owner.ownerProfile.altPhoneNumber!,
                    Icons.phone_outlined,
                  ),
                ],
                if (tenancy.tenantable.unit.property.owner.email != null) ...[
                  const Divider(height: 24),
                  _buildEnhancedDetailRow(
                    'Email',
                    tenancy.tenantable.unit.property.owner.email,
                    Icons.email_outlined,
                  ),
                ],
                if (tenancy.tenantable.unit.property.owner.ownerProfile.addressLine1 != null) ...[
                  const Divider(height: 24),
                  _buildEnhancedDetailRow(
                    'Address',
                    tenancy.tenantable.unit.property.owner.ownerProfile.addressLine1!,
                    Icons.location_on_outlined,
                  ),
                ],
                if (tenancy.tenantable.unit.property.owner.ownerProfile.nationality != null) ...[
                  const Divider(height: 24),
                  _buildEnhancedDetailRow(
                    'Nationality',
                    tenancy.tenantable.unit.property.owner.ownerProfile.nationality!,
                    Icons.flag_outlined,
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('Tenant Information'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.all(20),
              title: _buildPartyRow(
                'Tenant',
                tenancy.tenant.name,
                Icons.person_outline,
                Colors.blue,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                _buildEnhancedDetailRow(
                  'Email',
                  tenancy.tenant.email,
                  Icons.email_outlined,
                ),
                if (tenancy.tenant.tenantProfile != null) ...[
                  const Divider(height: 24),
                  _buildEnhancedDetailRow(
                    'NRIC',
                    tenancy.tenant.tenantProfile!.nricNumber,
                    Icons.badge_outlined,
                  ),
                  const Divider(height: 24),
                  _buildEnhancedDetailRow(
                    'Nationality',
                    tenancy.tenant.tenantProfile!.nationality,
                    Icons.flag_outlined,
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),
        
        _buildSectionTitle('Financial Terms'),
        const SizedBox(height: 8),
        _buildDetailCard([
          if (tenancy.agreement.securityDeposit > 0) ...[
            _buildEnhancedDetailRow(
              'Security Deposit',
              'RM ${tenancy.agreement.securityDeposit.toStringAsFixed(2)}',
              Icons.shield_outlined,
            ),
          ],
          if (tenancy.agreement.keyDeposit > 0) ...[
            const Divider(height: 24),
            _buildEnhancedDetailRow(
              'Key Deposit',
              'RM ${tenancy.agreement.keyDeposit.toStringAsFixed(2)}',
              Icons.key_outlined,
            ),
          ],
          if (tenancy.agreement.advancedRentalAmount > 0) ...[
            const Divider(height: 24),
            _buildEnhancedDetailRow(
              'Advanced Rental',
              'RM ${tenancy.agreement.advancedRentalAmount.toStringAsFixed(2)}',
              Icons.payment_outlined,
            ),
          ],
        ]),
        
        if (tenancy.agreement.paymentBankName != null) ...[
          const SizedBox(height: 16),
          _buildSectionTitle('Payment Details'),
          const SizedBox(height: 8),
          _buildDetailCard([
            _buildEnhancedDetailRow(
              'Bank Name',
              tenancy.agreement.paymentBankName!,
              Icons.account_balance_outlined,
            ),
            if (tenancy.agreement.paymentBankHolderName != null) ...[
              const Divider(height: 24),
              _buildEnhancedDetailRow(
                'Account Holder',
                tenancy.agreement.paymentBankHolderName!,
                Icons.person_outline,
              ),
            ],
            if (tenancy.agreement.paymentBankAccountNumber != null) ...[
              const Divider(height: 24),
              _buildEnhancedDetailRow(
                'Account Number',
                tenancy.agreement.paymentBankAccountNumber!,
                Icons.numbers_outlined,
              ),
            ],
          ]),
        ],
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTenancyDetailsTab(BuildContext context, Tenancy tenancy) {
    const Color primaryColor = Color(0xFF076633);
    
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildPropertyCard(tenancy),
        const SizedBox(height: 16),
        
        _buildSectionTitle('Property Details'),
        const SizedBox(height: 8),
        _buildDetailCard([
          _buildEnhancedDetailRow(
            'Property',
            tenancy.tenantable.unit.property.propertyName,
            Icons.apartment_outlined,
          ),
          const Divider(height: 24),
          _buildEnhancedDetailRow(
            'Type',
            tenancy.tenantable.unit.property.propertyType,
            Icons.category_outlined,
          ),
          const Divider(height: 24),
          _buildEnhancedDetailRow(
            'Unit',
            tenancy.tenantable.unit.blockFloorUnitNumber,
            Icons.door_front_door_outlined,
          ),
          const Divider(height: 24),
          _buildEnhancedDetailRow(
            'Room',
            tenancy.tenantable.name,
            Icons.meeting_room_outlined,
          ),
          const Divider(height: 24),
          _buildEnhancedDetailRow(
            'Rental Type',
            tenancy.tenantable.unit.rentalType,
            Icons.home_work_outlined,
          ),
        ]),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('Address'),
        const SizedBox(height: 8),
        _buildDetailCard([
          _buildAddressRow(tenancy.tenantable.unit.property),
        ]),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('Unit Features'),
        const SizedBox(height: 8),
        _buildFeaturesCard(tenancy.tenantable.unit),
        
        const SizedBox(height: 16),
        
        _buildSectionTitle('Rental Information'),
        const SizedBox(height: 8),
        _buildDetailCard([
          _buildFinancialRow(
            'Monthly Rental',
            'RM ${tenancy.rentalFee.toStringAsFixed(2)}',
            primaryColor,
          ),
          const Divider(height: 24),
          _buildEnhancedDetailRow(
            'Payment Frequency',
            tenancy.rentalPaymentFrequency,
            Icons.repeat_outlined,
          ),
          const Divider(height: 24),
          _buildEnhancedDetailRow(
            'Period',
            '${tenancy.tenancyPeriodStartDate} to ${tenancy.tenancyPeriodEndDate}',
            Icons.calendar_month_outlined,
          ),
        ]),
        
        if (tenancy.tenantable.meters.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionTitle('Smart Meter'),
          const SizedBox(height: 8),
          _buildMeterCard(tenancy.tenantable.meters.first),
        ],
        
        if (tenancy.remarks.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionTitle('Additional Information'),
          const SizedBox(height: 8),
          _buildDetailCard([
            _buildRemarksRow(tenancy.remarks),
          ]),
        ],
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDocumentsTab(BuildContext context, Tenancy tenancy) {
    final documents = tenancy.agreement.attachmentUrls;

    if (documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No documents available',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tenancy Agreement',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${documents.length} document(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Sign Document Button
              IconButton(
                icon: const Icon(Icons.draw_outlined),
                onPressed: () => _showSignatureDialog(context),
                tooltip: 'Sign Document',
                color: const Color(0xFF076633),
              ),
              // Download Button
              IconButton(
                icon: const Icon(Icons.download_outlined),
                onPressed: () => _downloadPdf(documents.first),
                tooltip: 'Download',
                color: const Color(0xFF076633),
              ),
            ],
          ),
        ),
        Expanded(
          child: SfPdfViewer.network(
            documents.first,
            canShowScrollHead: true,
            canShowScrollStatus: true,
          ),
        ),
      ],
    );
  }

  // Helper Methods
  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _downloadPdf(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showSignatureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const SignatureDialog(),
    );
  }

  // UI Widgets
  Widget _buildStatusCard(Tenancy tenancy, int daysRemaining, Color primaryColor) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (tenancy.status == 'Active') {
      if (daysRemaining < 30) {
        statusColor = Colors.orange;
        statusIcon = Icons.warning_amber_outlined;
        statusText = 'Expiring Soon';
      } else {
        statusColor = primaryColor;
        statusIcon = Icons.check_circle_outline;
        statusText = 'Active';
      }
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.cancel_outlined;
      statusText = tenancy.status;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(statusIcon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusInfo('Days Left', '$daysRemaining'),
              Container(width: 1, height: 40, color: Colors.white30),
              _buildStatusInfo('Payment Day', '${tenancy.agreement.paymentDueDay}th'),
              Container(width: 1, height: 40, color: Colors.white30),
              _buildStatusInfo('Monthly', 'RM ${tenancy.rentalFee.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Tenancy tenancy) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              image: tenancy.tenantable.unit.unitImagesUrls.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(tenancy.tenantable.unit.unitImagesUrls.first),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: tenancy.tenantable.unit.unitImagesUrls.isEmpty
                ? Center(
                    child: Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenancy.fullPropertyName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusBadge(tenancy.status),
                    const SizedBox(width: 8),
                    _buildStatusBadge(tenancy.tenantable.status),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeterCard(Meter meter) {
    Color statusColor = meter.connectionStatus == 'online' ? Colors.green : Colors.grey;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                meter.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      meter.connectionStatus.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMeterInfo(
                  'Balance',
                  '${meter.balanceUnit.toStringAsFixed(2)} kWh',
                  Icons.bolt_outlined,
                  Colors.blue,
                ),
              ),
              Container(width: 1, height: 50, color: Colors.grey[200]),
              Expanded(
                child: _buildMeterInfo(
                  'Used',
                  '${meter.usedUnit.toStringAsFixed(2)} kWh',
                  Icons.trending_up_outlined,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rate: RM ${meter.unitPricePerUnit}/kWh',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Serial: ${meter.serialNumber}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeterInfo(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = const Color(0xFF076633);
        break;
      case 'occupied':
        color = Colors.blue;
        break;
      case 'fully occupied':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFeaturesCard(Unit unit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFeatureItem(Icons.bed_outlined, '${unit.bedroomCount}', 'Bedrooms'),
          Container(width: 1, height: 50, color: Colors.grey[200]),
          _buildFeatureItem(Icons.bathroom_outlined, '${unit.bathroomCount}', 'Bathrooms'),
          Container(width: 1, height: 50, color: Colors.grey[200]),
          _buildFeatureItem(Icons.square_foot_outlined, unit.squareFeet ?? 'N/A', 'Sq Ft'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: const Color(0xFF076633)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildEnhancedDetailRow(String title, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressRow(Property property) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on_outlined, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Address',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${property.addressLine1}\n${property.city}, ${property.postcode}\n${property.state}, ${property.country}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartyRow(String role, String name, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialRow(String label, String amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.attach_money, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRemarksRow(String remarks) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            remarks,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// Signature Dialog Widget - FIXED VERSION with Upload Option
class SignatureDialog extends StatefulWidget {
  const SignatureDialog({super.key});

  @override
  State<SignatureDialog> createState() => _SignatureDialogState();
}

enum SignatureMode { draw, upload }

class _SignatureDialogState extends State<SignatureDialog> {
  final List<Offset?> _points = [];
  SignatureMode _mode = SignatureMode.draw;
  String? _uploadedImagePath;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sign Document',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Mode Selector
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _mode = SignatureMode.draw;
                          _uploadedImagePath = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _mode == SignatureMode.draw
                              ? const Color(0xFF076633)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.draw_outlined,
                              size: 18,
                              color: _mode == SignatureMode.draw
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Draw',
                              style: TextStyle(
                                color: _mode == SignatureMode.draw
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _mode = SignatureMode.upload;
                          _points.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _mode == SignatureMode.upload
                              ? const Color(0xFF076633)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_file_outlined,
                              size: 18,
                              color: _mode == SignatureMode.upload
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Upload',
                              style: TextStyle(
                                color: _mode == SignatureMode.upload
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _mode == SignatureMode.draw
                  ? 'Draw your signature below'
                  : 'Upload your signature image',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            // Signature Canvas or Upload Area
            if (_mode == SignatureMode.draw)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _points.add(details.localPosition);
                      });
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _points.add(null);
                      });
                    },
                    child: CustomPaint(
                      painter: SignaturePainter(_points),
                      size: Size.infinite,
                    ),
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromARGB(255, 250, 250, 250),
                    ),
                  child: _uploadedImagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_uploadedImagePath!),
                            fit: BoxFit.contain,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: const Color.fromARGB(255, 83, 207, 16),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to upload signature',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PNG, JPG (Max 5MB)',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (_mode == SignatureMode.draw)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _points.clear();
                        });
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _uploadedImagePath != null
                          ? () {
                              setState(() {
                                _uploadedImagePath = null;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_mode == SignatureMode.draw && _points.isEmpty) ||
                            (_mode == SignatureMode.upload && _uploadedImagePath == null)
                        ? null
                        : () {
                            _submitSignature();
                          },
                    icon: const Icon(Icons.check),
                    label: const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: const Color(0xFF076633),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Check file size (5MB limit)
        final File file = File(image.path);
        final int fileSizeInBytes = await file.length();
        final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image size must be less than 5MB'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }

        setState(() {
          _uploadedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  void _submitSignature() {
    // TODO: Implement API call here
    if (_mode == SignatureMode.draw) {
      // Convert _points to image and send to API
      // final signatureImage = await _convertPointsToImage(_points);
      // await yourApiService.submitSignature(signatureImage);
    } else {
      // Upload the image file
      // await yourApiService.uploadSignature(File(_uploadedImagePath!));
    }
    
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signature submitted successfully'),
        backgroundColor: Color(0xFF076633),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Custom Painter for Signature
class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}