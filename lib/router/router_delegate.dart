/*
 * Copyright (c) 2021 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marieyayo/ui/photos.dart';
import '../app_state.dart';
import '../ui/login.dart';
import '../ui/movie_part_1.dart';
import '../ui/movie_part_2.dart';
import '../ui/presentation.dart';
import '../ui/settings.dart';
import '../ui/songs.dart';
import '../ui/splash.dart';
import 'back_dispatcher.dart';
import 'ui_pages.dart';

class ShoppingRouterDelegate extends RouterDelegate<PageConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageConfiguration> {
  final List<Page> _pages = [];
  late ShoppingBackButtonDispatcher backButtonDispatcher;

  @override
  final GlobalKey<NavigatorState> navigatorKey;
  final AppState appState;

  ShoppingRouterDelegate(this.appState) : navigatorKey = GlobalKey() {
    appState.addListener(() {
      notifyListeners();
    });
  }

  /// Getter for a list that cannot be changed
  List<MaterialPage> get pages => List.unmodifiable(_pages);

  /// Number of pages function
  int numPages() => _pages.length;

  @override
  PageConfiguration get currentConfiguration {
    print('currentConfiguration - enter');
    print(appState.currentAction.state);
    print(appState.currentAction.pageConfig);
    print(appState.currentAction.widget);
    if(appState.currentAction.pageConfig != null){
      return appState.currentAction.pageConfig!;
    }

    print((_pages.last.arguments as PageConfiguration).path);
    return _pages.last.arguments as PageConfiguration;
  }

  @override
  Widget build(BuildContext context) {
    print('build - enter');
    return Navigator(
      key: navigatorKey,
      onPopPage: _onPopPage,
      pages: buildPages(context),
    );
  }

  bool _onPopPage(Route<dynamic> route, result) {
    print('_onPopPage - enter');
    final didPop = route.didPop(result);
    if (!didPop) {
      return false;
    }
    if (canPop()) {
      print('can pop');
      pop(result);
      print('poped');
      return true;
    } else {
      print('cannot pop');
      return false;
    }
  }

  void _removePage(Page? page) {
    if (page != null) {
      _pages.remove(page);
    }
  }

  //TODO: ver si 'result' se puede tipar con Generics
  void pop([result]) {
    if (canPop()) {
      final pageConfig = _pages.last.arguments as PageConfiguration; //TODO: ver si PageConfiguration se puede tipar con Generics, con el mismo tipo del parámetro 'result'
      _removePage(_pages.last);
      if(pageConfig.currentPageAction != null && pageConfig.currentPageAction!.returnValueCompleter != null){
        if(result != null){
          pageConfig.currentPageAction!.returnValueCompleter!.complete(result);
        }
        else {
          //TODO: Esto es para los casos como la pantalla BatchDetails, que al volver de NewReturn no tiene valor de retorno, pero hay que hacerlo BIEN
          pageConfig.currentPageAction!.returnValueCompleter!.complete(true);
        }
      }
      else {
        notifyListeners();
      }
    }
  }

  bool canPop() {
    return _pages.length > 1;
  }

  @override
  Future<bool> popRoute() {
    if (canPop()) {
      _removePage(_pages.last);
      return Future.value(true);
    }
    return Future.value(false);
  }

  MaterialPage _createPage(Widget child, PageConfiguration pageConfig) {
    return MaterialPage(
        child: child,
        key: ValueKey(pageConfig.key),
        name: pageConfig.path,
        arguments: pageConfig);
  }

  void _addPageData(Widget child, PageConfiguration pageConfig) {
    print('_addPageData - enter');
    print(pageConfig.path);
    _pages.add(
      _createPage(child, pageConfig),
    );
    print('_addPageData - exit');
  }

  void addPage(PageConfiguration pageConfig) {
    final shouldAddPage = _pages.isEmpty ||
        (_pages.last.arguments as PageConfiguration).uiPage !=
            pageConfig.uiPage;
    if (shouldAddPage) {
      switch (pageConfig.uiPage) {
        case PageEnum.Splash:
          _addPageData(Splash(), SplashPageConfig);
          break;
        case PageEnum.Login:
          _addPageData(Login(), LoginPageConfig);
          break;
        case PageEnum.Presentation:
          _addPageData(const Presentation(), PresentationPageConfig);
          break;
        case PageEnum.MoviePart1:
          _addPageData(const MoviePart1(), MoviePart1PageConfig);
          break;
        case PageEnum.MoviePart2:
          _addPageData(const MoviePart2(), MoviePart2PageConfig);
          break;
        case PageEnum.Fotos:
          _addPageData(const Photos(), FotosPageConfig);
          break;
        case PageEnum.Songs:
          _addPageData(const Songs(), SongsPageConfig);
          break;
        case PageEnum.Settings:
          _addPageData(Settings(), SettingsPageConfig);
          break;
        default:
          break;
      }
    }
  }

  void replace(PageConfiguration newRoute) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    addPage(newRoute);
  }

  void setPath(List<MaterialPage> path) {
    _pages.clear();
    _pages.addAll(path);
  }

  void replaceAll(PageConfiguration newRoute) {
    setNewRoutePath(newRoute);
  }

  void push(PageConfiguration newRoute) {
    addPage(newRoute);
  }

  void pushWidget(Widget child, PageConfiguration newRoute) {
    _addPageData(child, newRoute);
  }

  void addAll(List<PageConfiguration> routes) {
    _pages.clear();
    routes.forEach((route) {
      addPage(route);
    });
  }

  @override
  Future<void> setNewRoutePath(PageConfiguration configuration) {
    final shouldAddPage = _pages.isEmpty ||
        (_pages.last.arguments as PageConfiguration).uiPage !=
            configuration.uiPage;
    if (shouldAddPage) {
      _pages.clear();
      addPage(configuration);
    }
    return SynchronousFuture(null);
  }

  void _setPageAction(PageAction action) {
    switch (action.pageConfig!.uiPage) {
      case PageEnum.Splash:
        SplashPageConfig.currentPageAction = action;
        break;
      case PageEnum.Login:
        LoginPageConfig.currentPageAction = action;
        break;
      case PageEnum.Presentation:
        PresentationPageConfig.currentPageAction = action;
        break;
      case PageEnum.Settings:
        SettingsPageConfig.currentPageAction = action;
        break;
      case PageEnum.MoviePart1:
        MoviePart1PageConfig.currentPageAction = action;
        break;
      case PageEnum.MoviePart2:
        MoviePart2PageConfig.currentPageAction = action;
        break;
      case PageEnum.Fotos:
        FotosPageConfig.currentPageAction = action;
        break;
      case PageEnum.Songs:
        SongsPageConfig.currentPageAction = action;
        break;
      default:
        break;
    }
  }

  List<Page> buildPages(BuildContext context) {
    if (!appState.splashFinished) {
      replaceAll(SplashPageConfig);
    } else {
      switch (appState.currentAction.state) {
        case PageState.none:
          break;
        case PageState.addPage:
          _setPageAction(appState.currentAction);
          addPage(appState.currentAction.pageConfig!);
          break;
        case PageState.pop:
          pop(appState.currentAction.returnValue);
          break;
        case PageState.replace:
          _setPageAction(appState.currentAction);
          replace(appState.currentAction.pageConfig!);
          break;
        case PageState.replaceAll:
          _setPageAction(appState.currentAction);
          replaceAll(appState.currentAction.pageConfig!);
          break;
        case PageState.addWidget:
          _setPageAction(appState.currentAction);
          pushWidget(appState.currentAction.widget!, appState.currentAction.pageConfig!);
          break;
        case PageState.addAll:
          addAll(appState.currentAction.pages!);
          break;
      }
    }
    appState.resetCurrentAction();
    return List.of(_pages);
  }


  void parseRoute(Uri uri) {
    if (uri.pathSegments.isEmpty) {
      setNewRoutePath(SplashPageConfig);
      return;
    }

    // Handle navapp://deeplinks/details/#
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] == 'details') {
        //TODO:Arreglar esta y todas las rutas
        //pushWidget(const BatchDetails(batch: null), DetailsPageConfig);
      }
    } else if (uri.pathSegments.length == 1) {
      final path = uri.pathSegments[0];
      switch (path) {
        case 'splash':
          replaceAll(SplashPageConfig);
          break;
        case 'login':
          replaceAll(LoginPageConfig);
          break;
        case 'presentation':
          replaceAll(PresentationPageConfig);
          break;
        case 'settings':
          setPath([
            _createPage(Settings(), SettingsPageConfig)
          ]);
          break;
        case 'movie_part_1':
          setPath([
            _createPage(const Presentation(), PresentationPageConfig),
            _createPage(const MoviePart1(), MoviePart1PageConfig)
          ]);
          break;
        case 'movie_part_2':
          setPath([
            _createPage(const Presentation(), PresentationPageConfig),
            _createPage(const MoviePart2(), MoviePart1PageConfig)
          ]);
          break;
        case 'fotos':
          setPath([
            _createPage(const Presentation(), PresentationPageConfig),
            _createPage(const Photos(), FotosPageConfig)
          ]);
          break;
        case 'songs':
          setPath([
            _createPage(const Presentation(), PresentationPageConfig),
            _createPage(const Songs(), SongsPageConfig)
          ]);
          break;
      }
    }
  }
}
