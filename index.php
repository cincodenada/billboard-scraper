<html>
  <head>
    <title>Most of the #1 Billboard Hits I could find on Wikipedia</title>
    <script type="text/javascript" src="http://code.jquery.com/jquery-2.1.4.js"></script>
    <link rel="stylesheet" href="//cdn.datatables.net/1.10.9/css/jquery.dataTables.min.css"/>
    <link rel="stylesheet" href="//cdn.datatables.net/1.10.9/css/jquery.dataTables.min.css"/>
    <script type="text/javascript" src="//cdn.datatables.net/1.10.9/js/jquery.dataTables.min.js"></script>
    <style>
      .popup {
        display: none;
        position: absolute;
        top: 0px;
        right: 0px;
        background: white;
        border: 2px solid black;
        padding: 5px;
        width: 500px;
      }

      .dataTables_wrapper .dataTables_filter { float: left; }
      .dataTables_wrapper .dataTables_length { float: right; }
    </style>
  </head>
  <body>
    <pre style="display: none">
    <?php
      $fh = fopen('linkmap.tsv','r');
      $links = array();
      while($row = fgetcsv($fh, 10000, "\t")) {
        $links[$row[0]] = $row[1];
      }

      $fh = fopen('songs.tsv','r');
      $songs = array();
      while($row = fgetcsv($fh, 10000, "\t", "\0")) {
        if(empty($row[0]) && empty($row[1]) && empty($row[2])) {
          continue;
        }
        // Explode out the sources
        $sources = array();
        foreach(explode('; ', $row[2]) as $sourcedate) {
          list($source, $date) = explode(', ', $sourcedate, 2);
          if(empty($date)) { var_dump($row); print "<$sourcedate>\n"; }
          $sources[] = array(
            'source' => $source,
            'date' => $date,
            'link' => $links[$source],
          );
        }
        $row[2] = $sources;

        $songs[] = $row;
      }
    ?>
    </pre>
    <a href="songs.tsv">Download the source TSV for use in Excel, etc</a><br/>
    <table>
      <thead>
        <tr>
          <th>Artist</th>
          <th>Song</th>
          <th>Source chart(s)</th>
      </thead>
      <tbody>
        <?php foreach($songs as $row): ?>
        <tr>
          <td><?=$row[0]?></td>
          <td><?=$row[1]?></td>
          <td style="position: relative">
            <a href="" class="refcount">[<?=count($row[2])?>]</a>
            <div class="popup">
              <?php foreach($row[2] as $source): ?>
              <a href="http://en.wikipedia.org/wiki/<?=$source['link']?>">
                <?=$source['source']?></a>
              <?=$source['date']?>
              <br/>
              <?php endforeach ?>
            </div>
          </td>
        </tr>
        <?php endforeach ?>
      </tbody>
    </table>
    <script type="text/javascript">
      $('table').DataTable({
        dom: 'flrtip',
        lengthMenu: [100,500,1000,5000],
        language: {
          search: 'Search by song, artist, or chart:',
        }
      }); 
      $('table').on('mouseenter', '.refcount', function() {
        this.nextElementSibling.style.display = 'block';
      });
      $('table').on('mouseleave', '.popup', function() {
        this.style.display = 'none';
      });
    </script>
  </body>
</html>
