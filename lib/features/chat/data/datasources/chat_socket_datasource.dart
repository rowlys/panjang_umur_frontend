import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:panjang_umur_frontend/core/network/dio_client.dart';

import '../../domain/models/message.dart';
import '../../domain/models/read_receipt.dart';

class ChatSocketDataSource {
  final DioClient _client;

  WebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;
  final _messageController = StreamController<Message>.broadcast();
  final _readReceiptController = StreamController<ReadReceipt>.broadcast();

  ChatSocketDataSource({required this._client});

  Stream<Message> get messages => _messageController.stream;

  Stream<ReadReceipt> get readReceipts => _readReceiptController.stream;

  bool get isConnected => _channel != null;

  Future<void> connect() async {
    if (_channel != null) return;

    final token = await _client.getToken();
    if (token == null) return;

    final uri = Uri.parse(
      '${GetWsBaseUrl()}/chat/ws',
    ).replace(queryParameters: {'token': token});

    final channel = WebSocketChannel.connect(uri);
    _channel = channel;

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
    _channelSubscription = null;
  }

  void send(String recipientId, String body) {
    _channel?.sink.add(jsonEncode({'recipientId': recipientId, 'body': body}));
  }

  Future<void> disconnect() async {
    final channel = _channel;
    _channel = null;
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    await channel?.sink.close();
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _readReceiptController.close();
  }
}
