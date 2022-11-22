import 'dart:convert';
import 'dart:async';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:web_scrapping/bloc.dart';
import 'package:web_scrapping/viewImage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'webView.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(),
      child: MaterialApp(
        title: 'Flutter Demo',
        // darkTheme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: WebViewExample(),
      ),
    );
  }
}

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController _searchTerm = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getWebsiteData();
  }

// Reference to webview controller
  var title;
  List<String?> medContent = [];
  var medNames;
  List<String> medLinks = [];
  List<String?> medImages = [];
  int countBack = 5;
  // Stream reduceCount() async* {
  //   Future.delayed(Duration(seconds: 1), () {
  //     setState(() {
  //       countBack = countBack - 1;
  //     });
  //   });

  //   yield countBack;
  // }

  String url = "";

  String? searchMedicine;
  WebViewController? _controller;
  getWebsiteData(String rawHtml) async {
    // final response = await http.get(Uri.parse("https://www.1mg.com/search/all?name=para"));
    // dom.Document html = dom.Document.html(response.body);
    final soup = BeautifulSoup(rawHtml);
    // final title = soup.findAll("div").map((e) => e).toList().sublist(20, 100);
    // final medContent = soup.findAll("div", class_: "col-6 bodyRegular textPrimary marginTop-8").map((e) => e.text).last;
    final medNames = soup.findAll("div", class_: "bodySemiBold textPrimary marginTop-4 HorizontalProductTile__header__vAQQE").map((e) => e.text).toList();
    setState(() {});
    List<String?> medImages = [];
    final getImages = soup.findAll("img").map((e) => e).toList();

    for (var element in getImages) {
      // print("id ===> ${element.id}");
      // print("class ===>${element.className}");
      if (medNames.contains(element.attributes["title"])) {
        medImages.add(element.attributes["src"]);
        print(element);
      }
    }
    setState(() {
      this.medNames = medNames;
      this.medImages = medImages;
    });

    List<String> medLinks = [];
    // List<String?> medContent = [];
    final getLinks = soup.findAll("a", class_: "noAnchorColor").map((e) {
      print("all links: ${e.attributes["href"]}");
      if (e.attributes["href"]!.contains("/drugs/") || e.attributes["href"]!.contains("/otc/")) {
        medLinks.add("https://www.1mg.com${e.attributes["href"]!}");
      }
    }).toList();
    setState(() {
      this.medLinks = medLinks;
    });
    for (var element in medNames) {
      print(element);
    }
    for (var element in medLinks) {
      // print("id ===> ${element.id}");
      // print("class ===>${element.className}");

      final response = await http.get(Uri.parse(element));
      final soup = BeautifulSoup(response.body);
      // medContent.add(soup.find("div", class_: "col-6 bodyRegular textPrimary marginTop-8")?.text);
      setState(() {
        this.medContent.add(soup.find("div", class_: "col-6 bodyRegular textPrimary marginTop-8")?.text);
      });
      print(element);
    }
    print(medContent);
    // title.forEach((element) {
    //todo: to know actual  classes
    //   print("id ===> ${element.id}");
    //   print("class ===>${element.className}");
    //   print(element.text);
    // });
    // dom.Document html = parser.parse(rawHtml);
    // final title = html.getElementById("drug_header")?.innerHtml;
    // print(title);
    // final title = html.getElementsByClassName("main-content doctors-main-content")[0].text;
    // setState(() {
    //   this.medContent = medContent;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, String?>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Search Your Medicine'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Positioned(
                    child: Offstage(
                  offstage: true,
                  child: searchMedicine == null
                      ? Container()
                      : Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: WebView(
                            initialUrl: url,
                            javascriptMode: JavascriptMode.unrestricted,
                            onWebViewCreated: (WebViewController webViewController) {
                              // Get reference to WebView controller to access it globally
                              _controller = webViewController;
                            },
                            onPageFinished: (String url) async {
                              print('Page finished loading: ');

                              await Future.delayed(Duration(seconds: 5), () async {
                                final html = await _controller?.runJavascriptReturningResult("new XMLSerializer().serializeToString(document)");

                                getWebsiteData(json.decode(html!));
                              });
                            },
                          ),
                        ),
                )),
                Positioned(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Form(
                        key: _formkey,
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            TextFormField(
                              onChanged: (value) {
                                _formkey.currentState!.save();
                              },
                              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)), label: Text("Search for a Medicine")),
                              controller: _searchTerm,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "First enter name of medicine";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            MaterialButton(
                              onPressed: () {
                                if (_formkey.currentState!.validate()) {
                                  setState(() {
                                    searchMedicine = _searchTerm.text;
                                    medNames = null;
                                    medLinks = [];
                                    medContent = [];
                                    // countBack = 6;

                                    url =
                                        'https://www.1mg.com/search/all?name=${_searchTerm.text}&filter=true&product_form=Tablet%2COral%20Suspension%2CSuspension%2CSyrup%2CTablet%20MR%2CTablet%20XR%2CTablet%20DR';
                                  });
                                  // reduceCount();
                                  if (_controller != null) {
                                    setState(() {
                                      _controller!.loadUrl(url);
                                    });
                                  }

                                  // setState(() {
                                  //   medNames = null;
                                  //   medLinks = [];
                                  //   searchMedicine = _searchTerm.text;
                                  // });
                                }
                              },
                              color: Colors.grey.shade600,
                              child: Text("Search"),
                            )
                          ],
                        ),
                      ),
                      medNames == null || medLinks.isEmpty
                          ? Container(
                              child: searchMedicine != null ? Text("Loading Results...") : Container(),
                            )
                          : Container(
                              height: 800,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: medLinks.length,
                                itemBuilder: ((context, index) {
                                  return ListTile(
                                    // horizontalTitleGap: 0,
                                    contentPadding: EdgeInsets.all(10.0),
                                    leading: medImages[index] != ""
                                        ? GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(MaterialPageRoute(builder: ((context) => ViewImage(medImages[index]!, medNames[index]))));
                                            },
                                            child: Image.network(
                                              alignment: Alignment.bottomCenter,
                                              medImages[index]!,
                                              fit: BoxFit.contain,
                                            ),
                                          )
                                        : Image.asset("lib/assets/med.png"),
                                    title: Text(medNames[index].toString(), style: TextStyle(fontSize: 20)),
                                    subtitle: medContent.length - 1 >= index
                                        ? Text(medContent[index].toString() == "null" ? "" : medContent[index].toString(), style: TextStyle(fontSize: 16))
                                        : Row(
                                            children: [
                                              Text("Loading Info"),
                                              SizedBox(width: 10),
                                              SizedBox(height: 10, width: 10, child: CircularProgressIndicator()),
                                            ],
                                          ),
                                    onTap: () {
                                      if (medLinks.isNotEmpty) {
                                        Navigator.of(context).push(MaterialPageRoute(builder: ((context) => OpenBrowserView(medLinks[index], medNames[index]))));
                                      }
                                    },
                                  );
                                }),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // JavascriptChannel _extractDataJSChannel(BuildContext context) {
  //   return JavascriptChannel(
  //     name: 'Flutter',
  //     onMessageReceived: (JavascriptMessage message) {
  //       String pageBody = message.message;
  //       print('page body: $pageBody');
  //     },
  //   );
  // }
}
