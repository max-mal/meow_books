import 'package:flutter/material.dart';
import 'package:flutter_app/models/book.dart';
import 'package:flutter_app/models/genre.dart';
import 'package:flutter_app/parts/book.dart';
import 'package:flutter_app/parts/bottomNavBar.dart';
import 'package:flutter_app/parts/listMoreButton.dart';
import 'package:flutter_app/utils/transparent.dart';
import '../colors.dart';
import '../globals.dart';

class CategoryScreen extends StatefulWidget {
  final Function goTo;
  final Genre genre;

  const CategoryScreen({
    Key key,
    this.goTo,
    this.genre,
  }) : super(key: key);

  _CategoryScreenState createState() => _CategoryScreenState();

  static open(context, Genre category, Function goTo) async {
    await Navigator.of(context).push(
        TransparentRoute(builder: (BuildContext context) => CategoryScreen(goTo: goTo, genre: category))
    );
  }
}

class _CategoryScreenState extends State<CategoryScreen> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  List<Book> books = [];

  bool isPopular = false;
  bool isLast = true;
  bool isLoading = false;
  bool isMoreLoading = false;
  int page = 1;
  bool showMoreButton = true;

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    snackBarContext = context;
    getRecommendations();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        title: widget.genre.name,        
      ),
      body: new SingleChildScrollView(
          child: Container(
            child: this.booksBlock(),
          )
      ),
    );
  }

  void getRecommendations({bool append = false}) async {
    setState(() {
      if (!append) {
        books = [];
        isLoading = true;
      } else {
        isMoreLoading = true;
      }

    });

    List<dynamic> list = [];

    if (isPopular) {
      list = await serverApi.getGenreBooks(widget.genre, popular: true, page: page);
    }

    if (isLast) {
      list = await serverApi.getGenreBooks(widget.genre, page: page);
    }

    if (append) {
      for (Book book in list) {
        books.add(book);
      }
    } else {
      books = List<Book>.from(list);
    }
    
    if (!mounted) {
      return;
    }
    setState((){
      isLoading = false;
      isMoreLoading = false;

      if (append && list.length == 0) {
        showMoreButton = false;
      }
    });
  }

  Widget booksBlock()
  {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(this.widget.genre.description ?? '', style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
            )),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 30),
                  child: GestureDetector(
                      child: Text('Популярные', style: TextStyle(color: isPopular? AppColors.secondary: AppColors.grey, fontSize: 14)),
                      onTap: () {
                        setState(() {
                          this.isPopular = true;
                          this.isLast = false;
                          showMoreButton = true;
                          page = 1;
                        });
                        getRecommendations();
                    },
                  ),
                ),
                Container(
                  child: GestureDetector(
                      child: Text('Последние', style: TextStyle(color: isLast? AppColors.secondary: AppColors.grey, fontSize: 14)),
                      onTap: () {
                        setState(() {
                          this.isPopular = false;
                          this.isLast = true;
                          showMoreButton = true;
                          page = 1;
                        });
                        getRecommendations();
                      },
                  ),
                )
              ],
            ),
          ),
          Container(
            child: this.booksListView(),

          ),
          moreButton(),
        ],
      ),
    );
  }

  Widget booksListView()
  {
    if (isLoading) {
      return Container(margin: EdgeInsets.only(top: 50),child: Center(child: CircularProgressIndicator()));
    }

    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (BuildContext ctx, int index) {
          return Container(
            child: Divider(
              color: AppColors.primary,
              height: 2,
            ),
          );
        },
        itemBuilder: (BuildContext ctx, int index) {
          Book item = books[index];
          return BookWidget(book: item);
        },
        itemCount: books.length
    );

  }

  Widget moreButton() {

    if (books.length < 10) {
      return Container();
    }
    
    return ListMoreButton(
      isLoading: isLoading,
      isMoreLoading: isMoreLoading,
      onMore: (){
        page += 1;
        getRecommendations(append: true);
      },
      showMoreButton: showMoreButton,
    );
  }


}