import 'json.dart';

/// Answer to linking a contact by phone number.
class PhoneLink {
  const PhoneLink(this.contact, {required this.onDaira, this.appUrl});
  final Contact contact;
  final bool onDaira;

  /// Where an invited person gets the app.
  final String? appUrl;
}

/// One of the organizer's contacts: a person they put in circles, maybe linked
/// to a Daira account (GET /contacts).
class Contact {
  const Contact({
    required this.id,
    required this.name,
    this.phone,
    this.registered = false,
    this.accountName,
    this.linkPending = false,
    this.circles = 0,
    this.activeCircles = 0,
    this.onTime = 0,
    this.late = 0,
    this.circleList = const [],
  });

  factory Contact.fromJson(Json json) {
    final record = json.obj('record');
    return Contact(
      id: json.str('id'),
      name: json.str('name'),
      phone: json.strOrNull('phone'),
      registered: json.flag('registered'),
      accountName: json.strOrNull('account_name'),
      linkPending: json.flag('link_pending'),
      circles: json.integer('circles'),
      activeCircles: json.integer('active_circles'),
      onTime: record.integer('on_time'),
      late: record.integer('late'),
      circleList: [for (final c in json.list('circle_list')) ContactCircle.fromJson(c)],
    );
  }

  final String id;
  final String name;
  final String? phone;

  /// Linked to a Daira account («مسجَّل»).
  final bool registered;

  /// The account's own name, when linked.
  final String? accountName;

  /// A link request is waiting for the account owner.
  final bool linkPending;
  final int circles;
  final int activeCircles;

  /// Commitment record (detail only): installments paid on time / late.
  final int onTime;
  final int late;
  final List<ContactCircle> circleList;

  /// The account's name differs from the name the organizer wrote.
  bool get nameDiffers => accountName != null && accountName!.trim() != name.trim();
}

class ContactCircle {
  const ContactCircle({required this.id, required this.name, required this.status});
  factory ContactCircle.fromJson(Json json) =>
      ContactCircle(id: json.str('id'), name: json.str('name'), status: json.str('status'));
  final String id;
  final String name;
  final String status;
}

/// A request to link a contact and an account (GET /links).
class LinkRequest {
  const LinkRequest({
    required this.id,
    required this.kind,
    required this.incoming,
    required this.name,
    required this.organizer,
    this.accountName,
    this.circleId,
    this.circle,
    this.createdAt,
  });

  factory LinkRequest.fromJson(Json json) => LinkRequest(
    id: json.str('id'),
    kind: json.str('kind'),
    incoming: json.flag('incoming'),
    name: json.str('name'),
    organizer: json.str('organizer'),
    accountName: json.strOrNull('account_name'),
    circleId: json.strOrNull('circle_id'),
    circle: json.strOrNull('circle'),
    createdAt: json.date('created_at'),
  );

  final String id;

  /// code: the organizer used my account ID · invite: someone used an
  /// invitation (the organizer approves) · add: the organizer added me to a circle.
  final String kind;

  /// I am the one who answers.
  final bool incoming;

  /// The name the organizer gave the contact.
  final String name;
  final String organizer;
  final String? accountName;
  final String? circleId;
  final String? circle;
  final DateTime? createdAt;
}

/// An organizer who linked me as one of their contacts.
class LinkedOrganizer {
  const LinkedOrganizer({required this.id, required this.organizer, required this.name});
  factory LinkedOrganizer.fromJson(Json json) =>
      LinkedOrganizer(id: json.str('id'), organizer: json.str('organizer'), name: json.str('name'));

  /// The contact id (used to leave the link).
  final String id;
  final String organizer;

  /// The name that organizer uses for me.
  final String name;
}

class LinksOverview {
  const LinksOverview({this.requests = const [], this.links = const []});
  factory LinksOverview.fromJson(Json json) => LinksOverview(
    requests: [for (final r in json.list('requests')) LinkRequest.fromJson(r)],
    links: [for (final l in json.list('links')) LinkedOrganizer.fromJson(l)],
  );

  final List<LinkRequest> requests;
  final List<LinkedOrganizer> links;

  List<LinkRequest> get incoming => [for (final r in requests) if (r.incoming) r];
  List<LinkRequest> get outgoing => [for (final r in requests) if (!r.incoming) r];
}

/// "DA-7K3M9Q" from whatever was typed or scanned ("da 7k3m9q", a link…).
String? normalizeAccountCode(String input) {
  final match = RegExp(r'DA[\s\-]?([A-Z0-9]{6})', caseSensitive: false).firstMatch(input.trim());
  return match == null ? null : 'DA-${match.group(1)!.toUpperCase()}';
}
