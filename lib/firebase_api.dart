import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'chats.dart';
import 'comments.dart';
import 'saves.dart';
import 'utils.dart';
import 'user.dart';
import 'message.dart';
import 'posts.dart';
import 'comments.dart';
class FirebaseApi {
  static Stream<List<User>> getUsers() => FirebaseFirestore.instance
      .collection('users')
      .orderBy(UserField.lastMessageTime, descending: true)
      .snapshots()
      .transform(Utils.transformer(User.fromJson));
  static Stream<List<Post>> getPosts() => FirebaseFirestore.instance
      .collection('posts')
      .orderBy(PostField.postDate, descending: true)
      .snapshots()
      .transform(Utils.transformer(Post.fromJson));
  static Stream<List<Comment>> getComments(String postId) => FirebaseFirestore.instance
      .collection('comments')
      .where("postId", isEqualTo: "$postId")
      .orderBy(CommentField.commentDate, descending: true)
      .snapshots()
      .transform(Utils.transformer(Comment.fromJson));
  static Stream<List<Post>> getPostsUser(String idUser) => FirebaseFirestore.instance
      .collection('posts')
      .where("idUser", isEqualTo: "$idUser")
      .orderBy(PostField.postDate, descending: true)
      .snapshots()
      .transform(Utils.transformer(Post.fromJson));
  static Stream<List<Chat>> getChats() => FirebaseFirestore.instance
      .collection('chats')
      .snapshots()
      .transform(Utils.transformer(Chat.fromJson));
  static Future uploadMessage(String idUser, String message, String urlAvatar, String username, String chatId, String imgUrl) async {
    final refMessages =
     FirebaseFirestore.instance.collection('chat').doc('$chatId').collection('messages');
      final newMessage = Message(
        idUser: idUser,
        urlAvatar: urlAvatar,
        username: username,
        message: message,
        createdAt: DateTime.now(),
      );
      await refMessages.add(newMessage.toJson());



    final refUsers = FirebaseFirestore.instance.collection('users');
    await refUsers
        .doc(idUser)
        .update({UserField.lastMessageTime: DateTime.now()});
  }

  static Stream<List<Message>> getMessages(String chatId) =>
          FirebaseFirestore.instance
          .collection('chat')
          .doc('$chatId')
          .collection('messages')
          .orderBy(MessageField.createdAt, descending: true)
          .snapshots()
          .transform(Utils.transformer(Message.fromJson));

  static Future addRandomUsers(List<User> users) async {
    final refUsers = FirebaseFirestore.instance.collection('users');

    final allUsers = await refUsers.get();
    if (allUsers.size != 0) {
      return;
    } else {
      for (final user in users) {
        final userDoc = refUsers.doc();
        final newUser = user.copyWith(idUser: userDoc.id);

        await userDoc.set(newUser.toJson());
      }
    }
  }
}