import multer from 'multer';

const storage = multer.memoryStorage();

// Allow up to 5 files with the field name 'files'
const upload = multer({ storage }).array('files', 5);

export default upload;
