import 'package:Medito/utils/utils.dart';

class SessionOptionsResponse {
  SessionData data;

  SessionOptionsResponse({data});

  SessionOptionsResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? SessionData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class SessionData {
  int id;
  String title;
  String alternativeTitle;
  String subtitle;
  String description;
  bool backgroundSound;
  String cover;
  String get coverUrl => cover?.toAssetUrl();
  String get backgroundImageUrl => backgroundImage?.toAssetUrl();
  String colorPrimary;
  String colorSecondary;
  String get attribution => author?.body ?? '';
  List<MediaFile> get files => audio.map((e) => e.file).toList()..removeWhere((element) => element == null);

  List<MediaFile> getFiles() {
    if (audio != null) {
      return audio.map((e) => e.file).toList()..removeWhere((element) => element == null);
    }
    if (avMedia != null) {
      return avMedia.map((e) => e.file).toList()..removeWhere((element) => element == null);
    }
  }

  @Deprecated('Use backgroundImageUrl instead')
  String backgroundImage;
  @Deprecated('use files instead')
  List<Audio> audio;
  @Deprecated('user attribution instead')
  Author author;
  List<AVMedia> avMedia;

  SessionData(
      {id,
        title,
        alternativeTitle,
        subtitle,
        description,
        backgroundSound,
        cover,
        colorPrimary,
        colorSecondary,
        author,
        audio,
        avMedia
      });

  SessionData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    alternativeTitle = json['alternative_title'];
    subtitle = json['subtitle'];
    description = json['description'];
    backgroundSound = json['background_sound'];
    cover = json['cover'];
    backgroundImage = json['background_image'];
    colorPrimary = json['color_primary'];
    colorSecondary = json['color_secondary'];
    author =
    json['author'] != null ? Author.fromJson(json['author']) : null;
    if (json['audio'] != null) {
      audio = <Audio>[];
      json['audio'].forEach((v) {
        audio.add(Audio.fromJson(v));
      });
    }
    if (json['media'] != null) {
      avMedia = <AVMedia>[];
      json['media'].forEach((v) {
        avMedia.add(AVMedia.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['alternative_title'] = alternativeTitle;
    data['subtitle'] = subtitle;
    data['description'] = description;
    data['background_sound'] = backgroundSound;
    data['background_image'] = backgroundImage;
    data['cover'] = cover;
    data['color_primary'] = colorPrimary;
    data['color_secondary'] = colorSecondary;
    if (author != null) {
      data['author'] = author.toJson();
    }
    if (audio != null) {
      data['audio'] = audio.map((v) => v.toJson()).toList();
    }
    if (avMedia != null) {
      data['media'] = avMedia.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Author {
  String body;

  Author({body});

  Author.fromJson(Map<String, dynamic> json) {
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['body'] = body;
    return data;
  }
}

// TODO move to using only AVMedia
class Audio {
  MediaFile file;

  Audio({file});

  Audio.fromJson(Map<String, dynamic> json) {
    file = json['file'] != null ? MediaFile.fromJson(json['file']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (file != null) {
      data['file'] = file.toJson();
    }
    return data;
  }
}

class AVMedia {
  MediaFile file;

  AVMedia({file});

  AVMedia.fromJson(Map<String,dynamic> json) {
    file = json['file'] != null ? MediaFile.fromJson(json['file']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (file !=null) {
      data['file'] = file.toJson();
    }
    return data;
  }
}

class MediaFile {
  String id;
  String voice;
  String length;
  String type;

  MediaFile({id, voice, length,type});

  MediaFile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    voice = json['voice'];
    length = json['length'];
    type = json['type']; // audio or video
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['voice'] = voice;
    data['length'] = length;
    data['type'] = type; // audio or video
    return data;
  }
}
