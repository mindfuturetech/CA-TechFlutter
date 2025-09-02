import 'package:flutter/material.dart';

import '../../services/SignUpPage/Api_Service.dart';

class ApprovalPage extends StatefulWidget {
  final String token;

  const ApprovalPage({Key? key, required this.token}) : super(key: key);

  @override
  _ApprovalPageState createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  Map<String, dynamic>? userInfo;
  String status = 'LOADING'; // LOADING, VALID, EXPIRED, INVALID, ERROR
  bool actionPending = false;
  bool actionCompleted = false;

  @override
  void initState() {
    super.initState();
    _validateLink();
  }

  Future<void> _validateLink() async {
    try {
      final ApiResponse<Map<String, dynamic>> result = await ApiService.validateLink(widget.token);

      if (result.success) {
        final data = result.data;
        final code = data?['code'];

        if (code == 'VALID') {
          setState(() {
            userInfo = data?['userData'];
            status = 'VALID';
          });
        } else {
          setState(() {
            status = code ?? 'UNKNOWN'; // EXPIRED, INVALID, or null fallback
          });
        }
      } else {
        setState(() {
          status = 'ERROR';
        });
      }
    } catch (e) {
      setState(() {
        status = 'ERROR';
      });
    }
  }

  Future<void> _handleAction(String action) async {
    setState(() {
      actionPending = true;
    });

    try {
      final ApiResponse<Map<String, dynamic>> result = await ApiService.userAction(action, widget.token);

      if (result.success) {
        _showSnackBar('Your action has been processed successfully!', isError: false);
        setState(() {
          actionCompleted = true;
        });
      } else {
        _showSnackBar(result.message ?? 'Error in performing user action.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error in performing user action. Please try again later.', isError: true);
    } finally {
      setState(() {
        actionPending = false;
      });
    }
  }


  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildStatusMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(message, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (status == 'LOADING') {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (status == 'EXPIRED') return _buildStatusMessage('This link has expired!');
    if (status == 'INVALID') return _buildStatusMessage('This link is invalid or no longer available!');
    if (status == 'ERROR') return _buildStatusMessage('Something went wrong. Please try again.');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Approval Request'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: userInfo == null
            ? _buildStatusMessage('No user info available.')
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Business Type', userInfo!['businessType']),
            _buildInfoRow('Name', userInfo!['name']),
            _buildInfoRow('Mobile', userInfo!['mobile']),
            _buildInfoRow('Email', userInfo!['email']),
            _buildInfoRow('PAN', userInfo!['pan']),
            _buildInfoRow('Company Name', userInfo!['companyName']),
            _buildInfoRow('GST Number', userInfo!['gst']),
            _buildInfoRow('Shop Act License', userInfo!['shopAct']),
            const SizedBox(height: 10),
            const Text('Business Address:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(userInfo!['address'] ?? '', style: const TextStyle(fontSize: 16)),
            const Spacer(),
            if (!actionCompleted)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: Text(actionPending ? 'Processing...' : 'Approve'),
                    onPressed: actionPending ? null : () => _handleAction('approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: Text(actionPending ? 'Processing...' : 'Deny'),
                    onPressed: actionPending ? null : () => _handleAction('deny'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value ?? 'N/A'),
          ],
        ),
      ),
    );
  }
}
