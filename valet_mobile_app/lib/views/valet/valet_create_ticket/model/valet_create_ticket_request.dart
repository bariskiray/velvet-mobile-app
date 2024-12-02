class TicketCreateRequest {
  final int ticketId;

  TicketCreateRequest({
    required this.ticketId,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticket_id': ticketId,
    };
  }
}
