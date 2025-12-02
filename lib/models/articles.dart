class Articles {
    int id;
    String title;
    // "source": {
    // "id": null,
    // "name": "BBC News"
    // },
    String author;
    String description;
    String url;
    String urlToImage;
    String publishedAt;
    String content;
   Articles({
     required this.id,
     required this.title,
     required this.author,
     required this.content,
     required this.description,
     required this.publishedAt,
     required this.url,
     required this.urlToImage
   });

   // factory

}