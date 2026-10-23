import 'package:haqani/core/services/whatsapp_service.dart';

/// Records what would have been sent instead of opening WhatsApp.
class FakeWhatsAppService implements WhatsAppService {
  WhatsAppResult result = WhatsAppResult.opened;
  final sent = <({int studentId, String body})>[];

  @override
  Future<WhatsAppResult> sendToParent({required int studentId, required String body}) async {
    sent.add((studentId: studentId, body: body));
    return result;
  }
}
