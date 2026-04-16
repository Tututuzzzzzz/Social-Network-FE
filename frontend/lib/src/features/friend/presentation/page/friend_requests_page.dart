import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/friend_requests_bloc.dart';
import '../widgets/friend_request_tile.dart';

class FriendRequestsPage extends StatelessWidget {
  const FriendRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<FriendRequestsBloc>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: RefreshIndicator(
        onRefresh: () => bloc.loadRequests(),
        child: Builder(
          builder: (context) {
            if (bloc.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (bloc.error != null) {
              return Center(child: Text('Error: ${bloc.error}'));
            }
            if (bloc.requests.isEmpty) {
              return const Center(child: Text('No requests'));
            }
            return ListView.builder(
              itemCount: bloc.requests.length,
              itemBuilder: (context, index) {
                final req = bloc.requests[index];
                return FriendRequestTile(
                  request: req,
                  onAccept: () => bloc.accept(req.id),
                  onReject: () => bloc.reject(req.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
