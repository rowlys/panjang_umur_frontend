import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:panjang_umur_frontend/core/network/dio_client.dart';

import '../../domain/models/message.dart';
import '../../domain/models/read_receipt.dart';

class ChatSocketDataSource {
  final DioClient _client;

  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  Timer? _reconnectTimer;
  int _retryAttempt = 0;
  bool _disposed = false;

  final _messageController = StreamController<Message>.broadcast();
  final _readReceiptController = StreamController<ReadReceipt>.broadcast();

  ChatSocketDataSource({required this._client});

  Stream<Message> get messages => _messageController.stream;

  Stream<ReadReceipt> get readReceipts => _readReceiptController.stream;

  Future<void> connect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    if (_channel != null || _disposed) return;

    final token = await _client.getToken();
    if (token == null) return;

    final uri = Uri.parse(
      '${GetWsBaseUrl()}/chat/ws',
    ).replace(queryParameters: {'token': token});

    final channel = WebSocketChannel.connect(uri);
    _channel = channel;

    try {
      await channel.ready;
    } catch (_) {
      // Handshake failed (offline, server restart, ...). Try again later.
      _handleDisconnect(channel);
      return;
    }

    _retryAttempt = 0;

    _channelSubscription = channel.stream.listen(
      (raw) {
        final json = jsonDecode(raw as String) as Map<String, dynamic>;
        if (json.containsKey('error')) return;

        // Server frames are tagged {"type", "data"} so message and read-receipt
        // events can share one socket. Outbound send() below needs no such tag
        // since a client frame only ever means "send a message".
        final data = json['data'] as Map<String, dynamic>;
        switch (json['type']) {
          case 'message':
            _messageController.add(Message.fromJson(data));
          case 'read':
            _readReceiptController.add(ReadReceipt.fromJson(data));
        }
      },
      onDone: () => _handleDisconnect(channel),
      onError: (_) => _handleDisconnect(channel),
      cancelOnError: true,
    );
  }

  void _handleDisconnect(WebSocketChannel channel) {
    if (_channel != channel) return;
    _channel = null;
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _reconnectTimer?.cancel();

    final seconds = min(30, 1 << _retryAttempt);
    _retryAttempt = min(_retryAttempt + 1, 5);
    _reconnectTimer = Timer(Duration(seconds: seconds), connect);
  }

  /// Returns false when the message could not be handed to a live connection,
  /// so the caller can keep the text and ask the user to try again.
  Future<bool> send(String recipientId, String body) async {
    if (_channel == null) {
      await connect();
    }

    final channel = _channel;
    if (channel == null) return false;

    channel.sink.add(jsonEncode({'recipientId': recipientId, 'body': body}));
    return true;
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _retryAttempt = 0;

    final channel = _channel;
    _channel = null;
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    await channel?.sink.close();
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _messageController.close();
    _readReceiptController.close();
  }
}
