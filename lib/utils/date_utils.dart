
class DateUtils {

  static String formatPublishedDate(String dateString) {

    try {

      final dateTime = DateTime.parse(dateString);

      final now = DateTime.now();

      final difference = now.difference(dateTime);



      if (difference.inDays > 0) {

        return '${difference.inDays}d ago';

      } else if (difference.inHours > 0) {

        return '${difference.inHours}h ago';

      } else if (difference.inMinutes > 0) {

        return '${difference.inMinutes}m ago';

      } else {

        return 'just now';

      }

    } catch (e) {

      return dateString;

    }

  }

}

