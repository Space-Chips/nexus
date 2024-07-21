import 'package:flutter/material.dart';
import 'package:nexus/components/chat_components/team_home_page_components/top_item_list.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({super.key});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("N E X U S"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const TeamHomeTopItem(
                      title: 'BAGUETTECHS',
                      lastPost: "Oui oui baguette",
                      lastPostAuthor: "Yursen le chef d'équipe",
                      lastPostTime: '10/20/2028  20:30',
                    ),
                    const SizedBox(height: 20),
                    _buildSmallTeamCards(),
                    const SizedBox(height: 20),
                    _buildSmallTeamCards(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildJoinSection(),
            const SizedBox(height: 20),
            _buildCreateTeamButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 40),
              ),
              Text(
                'TEAMS',
                style: TextStyle(color: Colors.white, fontSize: 48),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRIVATE',
                style: TextStyle(
                    color: Color.fromARGB(150, 158, 158, 158), fontSize: 28),
              ),
              Text(
                'CHAT',
                style: TextStyle(
                    color: Color.fromARGB(150, 255, 255, 255), fontSize: 33.6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return Container(
      width: 354,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BAGUETTECHS',
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
          SizedBox(height: 20),
          Text(
            'Oui oui baguette',
            style: TextStyle(color: Color(0xFFCACACA), fontSize: 12),
          ),
          Text(
            "Yursen le chef d'équipe\n01/07/2024 20:30",
            style: TextStyle(color: Color(0xFF959595), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTeamCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSmallTeamCard('FRENCH'),
        _buildSmallTeamCard('GEEKOS'),
      ],
    );
  }

  Widget _buildSmallTeamCard(String title) {
    return Container(
      width: 167,
      height: 175,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 25),
          ),
          const Spacer(),
          const Text(
            'Oui oui baguette',
            style: TextStyle(color: Color(0xFFCACACA), fontSize: 12),
          ),
          const Text(
            "Yursen le chef d'équipe\n01/07/2024 20:30",
            style: TextStyle(color: Color(0xFF959595), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildNumberBox(index + 1)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(340, 41),
            backgroundColor: const Color(0xFF3A3A3A),
          ),
          child: const Text(
            'J O I N',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberBox(int number) {
    return Container(
      width: 31,
      height: 41,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1),
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildCreateTeamButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(340, 58),
        backgroundColor: Colors.black,
        side: const BorderSide(color: Colors.white),
      ),
      child: const Text(
        'C R E A T E     T E A M',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
