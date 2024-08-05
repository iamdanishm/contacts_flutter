import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  const MySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: SearchAnchor(
        builder: (context, controller) {
          return SearchBar(
            elevation: WidgetStateProperty.all(0.0),
            padding: const WidgetStatePropertyAll(
                EdgeInsets.only(left: 16, right: 8)),
            focusNode: FocusNode(),
            onTap: () => controller.openView(),
            controller: controller,
            keyboardType: TextInputType.text,
            hintText: "Search Contacts",
            hintStyle: WidgetStateProperty.all(Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.black45)),
            onChanged: (value) {},
            leading: const Icon(Icons.search),
            trailing: [
              PopupMenuButton(
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                        child: Text(
                      "Settings",
                      style: Theme.of(context).textTheme.titleMedium,
                    )),
                    PopupMenuItem(
                        child: Text("Help & Feedback",
                            style: Theme.of(context).textTheme.titleMedium)),
                  ];
                },
              ),
            ],
          );
        },
        suggestionsBuilder: (context, controller) {
          return List.generate(10, (index) {
            return ListTile(
              title: Text("Suggestion ${index + 1}"),
              onTap: () => controller.closeView(index.toString()),
            );
          });
        },
      ),
    );
  }
}
