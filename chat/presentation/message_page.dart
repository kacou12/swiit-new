
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:swiit/src/features/chat/presentation/chat_page.dart';
import 'package:swiit/src/features/search/widgets/search_text_field.dart';

class MyMessagePage extends StatefulWidget {
  const MyMessagePage({super.key});

  @override
  State<MyMessagePage> createState() => _MyMessagePageState();
}

class _MyMessagePageState extends State<MyMessagePage> {
  bool isShowSearch = false;
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              if (isShowSearch) {
                setState(() {
                  isShowSearch = false;
                });
              } else {
                context.pop();
              }
            },
            icon: const Icon(Icons.arrow_back)),
        actions: [
          if (!isShowSearch)
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyChatPage()));
                },
                icon: const Icon(Icons.group_outlined))
        ],
        title: isShowSearch
            ? MySearchTextFiel(
                searchController: _searchController,
              )
            : const Text(
                "Messages",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (!isShowSearch)
            Padding(
              padding: const EdgeInsets.all(15),
              child: InkWell(
                onTap: () {
                  setState(() {
                    isShowSearch = true;
                  });
                },
                child: Container(
                  height: 40,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.all(Radius.circular(3))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Search ",
                        style: TextStyle(color: Colors.grey[400], fontSize: 15),
                      ),
                      const Icon(Icons.search),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
