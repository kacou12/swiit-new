import 'package:flutter/material.dart';

class MyChatPage extends StatelessWidget {
  const MyChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 5,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(10)),
                  // child: ,
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Name account",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Online",
                      style: TextStyle(color: Colors.green[200], fontSize: 15),
                    )
                  ],
                )
              ],
            ),
          )),
      body: Column(
        children: [
          Expanded(child: Container()),
          Container(
            color: Colors.blueGrey[200],
            // height: 100,
            padding:
                const EdgeInsets.only(bottom: 20, top: 10, right: 10, left: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.attachment_sharp,
                      size: 20,
                    )),
                Expanded(
                    child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: const TextField(
                    // controller: searchController,
                    autofocus: true,
                    style: TextStyle(fontSize: 15),
                    maxLines: 5,
                    minLines: 1,
                    decoration: InputDecoration(
                        hintTextDirection: TextDirection.ltr,
                        contentPadding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                        filled: false,
                        border: InputBorder.none,
                        alignLabelWithHint: false,
                        hintText: "Whrite your message",
                        hintStyle: TextStyle(fontSize: 15)),
                  ),
                )),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: const CircleBorder()),
                  onPressed: () {},
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
