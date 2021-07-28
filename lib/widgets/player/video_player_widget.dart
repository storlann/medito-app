import 'dart:io';

import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:Medito/utils/strings.dart';
import 'package:Medito/widgets/main/app_bar_widget.dart';
import 'package:Medito/widgets/player/subtitle_text_widget.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:Medito/utils/colors.dart';
import 'package:Medito/network/player/player_bloc.dart';
import 'package:Medito/network/auth.dart';
import 'package:Medito/utils/stats_utils.dart';
import 'package:chewie/chewie.dart';
import 'package:Medito/network/cache.dart';
import 'package:Medito/network/downloads/downloads_bloc.dart';
import 'package:Medito/audioplayer/player_utils.dart';

class VideoPlayerWidget extends StatefulWidget {

  final String id;
  final normalPop;
  final MediaItem mediaItem;

  VideoPlayerWidget({this.id, this.normalPop, this.mediaItem});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {

  VideoPlayerController _controller;
  ChewieController _chewieController;

  bool _loaded = false;
  bool _hasBeenPlayed = false;
  bool _updatedStats = false;

  Color secondaryColor;
  Color primaryColorAsColor = MeditoColors.transparent;
  PlayerBloc _bloc;


  @override
  void initState() {
    super.initState();

    initVideoController();
  }

  void initVideoController() async {

        if (widget.mediaItem != null) {
          print('initializing video player with media item '+widget.mediaItem.id);

          var cachedVersionAvailable = false;
          cachedVersionAvailable = await DownloadsBloc.isMediaItemDownloaded(widget.mediaItem);

          if (cachedVersionAvailable) {
            print("Media item already downloaded, playing from cache");
            var filePath = (await getFilePath(widget.mediaItem.id));
            
            var f = File(filePath);
            var fExists = await f.exists();
            
			// if filePath contains a space the player will hang forever at initialize step on iOS (but work on Android)
            filePath = Uri.encodeFull(filePath);
			f = File(filePath);
            if(fExists) {
              print("Playing $f from cache...");
              _controller = VideoPlayerController.file(f);
            } else {
              print("cached file $f should exist but could not be found, defaulting to network playback");
              _controller = VideoPlayerController.network(
                  BASE_URL + 'assets/' + widget.mediaItem.id);
            }
          } else {
            print("Playing media from network");
            _controller = VideoPlayerController.network(
                BASE_URL + 'assets/' + widget.mediaItem.id);
          }
        await _controller.initialize();

        _chewieController = ChewieController(
            videoPlayerController: _controller,
            autoPlay: true,
            looping: true
        );

        // once the video has played through at least once,
        // update the SharedPreferences to record that
        _controller.addListener(() async {
          var duration = _controller.value.duration.inSeconds-1;
          var position = _controller.value.position.inSeconds;

          if (_hasBeenPlayed && position == 0) {
            _updatedStats = false;
          }

          if((duration - position) < 1 ) {
            //video has been played through...
            _hasBeenPlayed = true;

            if (!_updatedStats) {
              _updatedStats = true;
              var dataMap = {
                'secsListened': (duration+1),
                'id': '${widget.id}',
              };
              await writeJSONToCache(encoded(dataMap), 'stats');
              await updateStatsFromBg();
            }
          }
        });


        setState(() {
          _loaded = true;
        });
      } else {
          print('video widget called with a null mediaItem');// TODO... try again?
        }
  }


  @override
  Widget build(BuildContext context) {

    var aspectRatio = 1.0;
    if(_loaded) {
      print ("player loaded...");
      aspectRatio = _controller.value.aspectRatio;
    }
    return Scaffold(
      appBar: _getAppBar(widget.mediaItem),
      body: LayoutBuilder(
        builder: (context,constraints) {
          return SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: constraints.maxWidth * aspectRatio,
                height: constraints.maxHeight,
                child: _getVideoWidget()
              )
            )
          );
        },
      )

      /*body:  Stack(
                children: [
                  _getGradientWidget(widget.mediaItem, context),
                  _getGradientOverlayWidget(),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _getAppBar(widget.mediaItem),
                        _getTitleRow(widget.mediaItem),
                        _getSubtitleWidget(widget.mediaItem),
                        _getVideoWidget()
                    ]),
                  /*FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying ? _controller.pause() : _controller.play();
                        });
                      },
                      child: Icon(
                        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                      )
                  )*/
                ])*/
      );



  }


  Widget _getGradientOverlayWidget() {
    //if (!_loaded) return Container();
    return Image.asset(
      'assets/images/texture.png',
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      fit: BoxFit.fill,
    );
  }

  Widget _getVideoWidget() {

   if(_controller !=null && _controller.value.isInitialized) {
     /*return AspectRatio(aspectRatio: _controller.value.aspectRatio,
         child: VideoPlayer(_controller));*/
     return Chewie(
       controller: _chewieController,
     );
   }
    return _getLoadingScreenWidget();
  }


  Widget _getGradientWidget(MediaItem mediaItem, BuildContext context) {
    if (!_loaded ) return Container();
    return Align(
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  primaryColorAsColor.withAlpha(100),
                  primaryColorAsColor.withAlpha(0),
                ],
                radius: 1.0,
              )),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ));
  }


  MeditoAppBarWidget _getAppBar(MediaItem mediaItem) {
    return MeditoAppBarWidget(
      transparent: true,
      hasCloseButton: true,
      closePressed: _onBackPressed,
    );
  }

  void _onBackPressed() {
    //if (_complete || (widget.normalPop != null && widget.normalPop)) {
      Navigator.pop(context);
    /*} else {
      Navigator.popUntil(
          context,
              (Route<dynamic> route) =>
          route.settings.name == FolderNavWidget.routeName ||
              route.isFirst);
    }*/
  }

  Widget _getTitleRow(MediaItem mediaItem) {
    if (_bloc == null) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
              child: !_loaded
                  ? Text(
                mediaItem?.title ?? 'Loading...',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: buildTitleTheme(),
              )
                  : FutureBuilder<String>(
                  future: _bloc.getVersionTitle(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.hasData ? snapshot.data : 'Loading...',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: buildTitleTheme(),
                    );
                  })),
        ],
      ),
    );
  }

  TextStyle buildTitleTheme() {
    return Theme.of(context).textTheme.headline1;
  }

  Widget _getSubtitleWidget(MediaItem mediaItem) {
    var attr = '';
    if (_loaded && _bloc !=null) {
      attr = _bloc.version?.body ?? WELL_DONE_SUBTITLE;
    } else {
      attr = mediaItem?.extras != null ? mediaItem?.extras['attr'] : '';
    }

    return _loaded
        ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SubtitleTextWidget(body: attr),
    )
        : Container();
  }


  Center _getLoadingScreenWidget() {

    return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
                backgroundColor: Colors.black,
                valueColor:
                AlwaysStoppedAnimation<Color>(MeditoColors.walterWhite)),
            Container(height: 16),
            Text(_loaded ? WELL_DONE_COPY : LOADING)
          ],
        ));
  }



  @override
  void dispose() {
    _controller?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
