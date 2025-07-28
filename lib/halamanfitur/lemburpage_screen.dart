// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';


class LemburPage extends StatelessWidget {


        @override
        Widget build(BuildContext context) {
          return AppBar(
            title: const Text(
              'AppBarScreen',
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(LemburPage() as BuildContext).pop(),
            ),
            
            automaticallyImplyLeading: true,
          );
        }
      }
  


