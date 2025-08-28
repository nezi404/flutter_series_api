import 'package:app3_series_api/tv_show_grid.dart';
import 'package:app3_series_api/tv_show_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TvShowSearchScreen extends StatefulWidget {
  const TvShowSearchScreen({super.key});

  @override
  State<TvShowSearchScreen> createState() => _TvShowSearchScreenState();
}

class _TvShowSearchScreenState extends State<TvShowSearchScreen> {

  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  late Future<List<TvShow>>? searchResults;
  bool onSubmit = false;
  
  void submit () {
    if(_formKey.currentState!.validate()) {
      final tvShowModel = context.read<TvShowModel>();
      setState(() {
        searchResults = tvShowModel.searchTvShows(_controller.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
    padding: EdgeInsets.all(16),
    child: Column(children: [
      Text(
        "Buscar Séries 🎬",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        SizedBox(height:32),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: submit, icon: Icon(Icons.search)),
                  onSubmit ? IconButton(onPressed: () {
                    setState(() {
                      _controller.clear();
                      onSubmit = false;
                    });
                  }, icon: Icon(Icons.clear))
                  : Container() 
                ],
              )
            ),
            validator : (value) {
              if (value == null || value.isEmpty) {
                return "Título é obrigatório!";
              }
              return null;
            }
          )
        ),
        SizedBox(height: 16),
        onSubmit ? Expanded(
          child: FutureBuilder(
            future: searchResults, 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: SizedBox(
                  height: 96, 
                  width: 96, 
                  child: CircularProgressIndicator(strokeWidth: 12),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Container(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      spacing:32,
                      children: [
                      Text("Erro: ${snapshot.error}", style: TextStyle(fontSize: 24)),
                      ElevatedButton(
                        onPressed: () => context.go("/"), 
                        child: Text("Voltar"))
                      ]),
                  )
                );
              } else if (onSubmit && (!snapshot.hasData || snapshot.data!.isEmpty)) {
                return Center(
                  child: Container(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      spacing:32,
                      children: [
                      Text("Nenhuma série enconrtada 💔: ${snapshot.error}", style: TextStyle(fontSize: 24)),
                      ElevatedButton(
                        onPressed: () => context.go("/"), 
                        child: Text("Voltar"))
                      ]),
                  )
                );
              } else {
                return Column(
                  children: [ 
                    Text("${snapshot.data!.length} séries encontradas!",
                    style: TextStyle(fontSize: 18, 
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold)
                    ),
                    SizedBox(height: 16),
                    Expanded(child: 
                    TvShowGrid (tvShows: snapshot.data!), )
                  ],               
                );   
              }
            }
          ),
        ) : Container()
       ], 
      ),
    );
  }
}