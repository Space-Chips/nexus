import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nexus/services/user_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchUserData extends UserEvent {
  final String email;

  FetchUserData(this.email);

  @override
  List<Object?> get props => [email];
}

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;

  UserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserError extends UserState {
  final String message;

  UserError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial());

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is FetchUserData) {
      yield UserLoading();
      try {
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .where("email", isEqualTo: event.email)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
          var user = User(
            blockedUsersEmails:
                List<String>.from(userData['blockedUsersEmails'] ?? []),
            username: userData['username'] ?? '',
            isAdmin: userData['admin'] ?? false,
            email: userData['email'] ?? '',
          );
          yield UserLoaded(user);
        } else {
          yield UserError('User not found');
        }
      } catch (e) {
        yield UserError('Error fetching user data: $e');
      }
    }
  }
}
