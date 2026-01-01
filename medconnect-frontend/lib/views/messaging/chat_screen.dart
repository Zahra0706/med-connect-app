import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/chat_view_model.dart';
import '../../view_models/patient_auth_view_model.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final String otherUserName;

  ChatScreen({required this.conversationId, required this.otherUserName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  File? _selectedFile;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<PatientAuthViewModel>(context, listen: false).authResponse?.token;
      if (token != null) {
        final vm = Provider.of<ChatViewModel>(context, listen: false);
        vm.loadMessages(token, widget.conversationId);
        vm.startPolling(token, widget.conversationId);
      }
    });
  }

  @override
  void dispose() {
    // Note: ensure ViewModel stopPolling is called safely
    // Provider.of in dispose might be tricky if context is unmounted
    // But listen:false is usually okay. 
    // Best practice: ViewModel should handle dispose, but here we explicitly start polling for a specific ID.
    // The ViewModel is shared? If shared, stopping polling might stop it for others? 
    // But ChatViewModel seems to be designed for one active chat at a time regarding polling?
    // Actually startPolling overwrites the timer. So works for single active chat screen.
    // Future improvement: move state specifically to a per-screen provider.
    super.dispose();
  }

  @override
  void deactivate() {
     Provider.of<ChatViewModel>(context, listen: false).stopPolling();
     super.deactivate();
  }

  void _sendMessage() async {
    final token = Provider.of<PatientAuthViewModel>(context, listen: false).authResponse?.token;
    if (token == null) return;
    
    if (_controller.text.isEmpty && _selectedFile == null) return;

    final content = _controller.text;
    final file = _selectedFile;

    // Optimistic UI could be added here
    _controller.clear();
    setState(() {
      _selectedFile = null;
    });

    final success = await Provider.of<ChatViewModel>(context, listen: false)
        .sendMessage(token, widget.conversationId, content, file);
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Échec de l'envoi")));
    } else {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _pickFile() async {
    File? file = await Provider.of<ChatViewModel>(context, listen: false).pickFile();
    if (file != null) {
      setState(() {
        _selectedFile = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUserName)),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, viewModel, child) {
                 if (viewModel.isLoading && viewModel.messages.isEmpty) {
                   return Center(child: CircularProgressIndicator());
                 }
                 
                 // Auto scroll to bottom on new messages? 
                 // Simple implementation:
                 // WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                 // But this scrolls on every build (polling). Checks needed.

                 return ListView.builder(
                   controller: _scrollController,
                   itemCount: viewModel.messages.length,
                   itemBuilder: (context, index) {
                     final msg = viewModel.messages[index];
                     final isMe = msg.senderRole == 'PATIENT'; 
                     
                     // Mark as read if not me and not read
                     if (!isMe && !msg.isRead) {
                        // Avoid triggering too many requests during build
                        // Using postFrameCallback or check logic
                         WidgetsBinding.instance.addPostFrameCallback((_) {
                            final token = Provider.of<PatientAuthViewModel>(context, listen: false).authResponse?.token;
                            if (token != null) {
                               Provider.of<ChatViewModel>(context, listen: false).markMessageAsRead(token, msg.id);
                            }
                         });
                     }
                      
                     return Align(
                       alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                       child: Container(
                         margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                         padding: EdgeInsets.all(10),
                         decoration: BoxDecoration(
                           color: isMe ? Colors.blue[100] : Colors.grey[200],
                           borderRadius: BorderRadius.circular(10),
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             if (msg.content != null && msg.content!.isNotEmpty)
                               Text(msg.content!),
                             if (msg.fileUrl != null)
                               InkWell(
                                 onTap: () async {
                                   if (msg.fileUrl != null) {
                                      final Uri url = Uri.parse(msg.fileUrl!);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Impossible d'ouvrir le fichier")));
                                      }
                                   }
                                 },
                                 child: Container(
                                   margin: EdgeInsets.only(top: 5),
                                   padding: EdgeInsets.all(5),
                                   decoration: BoxDecoration(
                                     color: Colors.white,
                                     borderRadius: BorderRadius.circular(5),
                                     border: Border.all(color: Colors.grey)
                                   ),
                                   child: Row(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                                       SizedBox(width: 5),
                                       Text("Document PDF", style: TextStyle(color: Colors.blue)),
                                     ],
                                   ),
                                 ),
                               ),
                             SizedBox(height: 2),
                             Text(msg.sentAt, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                             if (isMe && msg.isRead) 
                                Icon(Icons.done_all, size: 12, color: Colors.blue)
                           ],
                         ),
                       ),
                     );
                   },
                 );
              },
            ),
          ),
          if (_selectedFile != null)
             Container(
               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
               color: Colors.grey[100],
               child: Row(
                 children: [
                   Icon(Icons.attach_file, size: 20),
                   SizedBox(width: 5),
                   Expanded(child: Text(_selectedFile!.path.split('/').last, overflow: TextOverflow.ellipsis)),
                   IconButton(icon: Icon(Icons.close, size: 20), onPressed: () => setState(() => _selectedFile = null))
                 ],
               ),
             ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, offset: Offset(0, -2))]),
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.attach_file), onPressed: _pickFile),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Écrire un message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(icon: Icon(Icons.send, color: Colors.white), onPressed: _sendMessage),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
