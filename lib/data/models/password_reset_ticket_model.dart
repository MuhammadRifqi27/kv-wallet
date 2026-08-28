/// Shared response shape for `POST /auth/password-reset-request` and
/// `GET /auth/password-reset-request/status` (see
/// docs/password-reset-request-flow.md). The submit response only carries
/// [ticketId]/[status] — [submittedAt]/[processedAt] are null until the
/// status endpoint is polled.
class PasswordResetTicket {
  const PasswordResetTicket({
    required this.ticketId,
    required this.status,
    this.submittedAt,
    this.processedAt,
  });

  factory PasswordResetTicket.fromJson(Map<String, dynamic> json) {
    return PasswordResetTicket(
      ticketId: json['ticket_id'] as int,
      status: json['status'] as String,
      submittedAt: json['submitted_at'] != null ? DateTime.parse(json['submitted_at'] as String) : null,
      processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at'] as String) : null,
    );
  }

  final int ticketId;
  final String status;
  final DateTime? submittedAt;
  final DateTime? processedAt;

  bool get isPending => status == 'pending';
  bool get isProcessed => status == 'processed';
  bool get isRejected => status == 'rejected';
}
